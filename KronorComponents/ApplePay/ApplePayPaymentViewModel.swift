//
//  ApplePayPaymentViewModel.swift
//  kronor-ios
//

import Foundation
import Kronor
import KronorApi
import KronorCdeApi
import PassKit
import os

@MainActor class ApplePayPaymentViewModel: ObservableObject {

    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: ApplePayPaymentViewModel.self)
    )

    static let defaultSupportedNetworks: [PKPaymentNetwork] = [.visa, .masterCard, .amex]

    private let stateMachine: ApplePayStatechart.ApplePayStateMachine
    private let networking: any ApplePayPaymentNetworking
    private let returnURL: URL
    private let merchantIdentifier: String
    private let merchantName: String
    private let supportedNetworks: [PKPaymentNetwork]
    private let countryCode: String
    private let paymentResultHandler: PaymentResultHandler

    private var paymentRequest: KronorApi.PaymentRequestFields?
    private var cdeToken: String?
    private var subscription: Task<Void, Never>?

    /// Keeps the payment sheet controller and its delegate alive while the
    /// sheet is presented: PassKit does not retain either of them.
    private var session: (controller: PKPaymentAuthorizationController, delegate: ApplePaySessionDelegate)?

    @Published var state: ApplePayStatechart.State

    init(
        stateMachine: ApplePayStatechart.ApplePayStateMachine,
        networking: some ApplePayPaymentNetworking,
        returnURL: URL,
        merchantIdentifier: String,
        merchantName: String,
        supportedNetworks: [PKPaymentNetwork],
        countryCode: String?,
        paymentResultHandler: @escaping PaymentResultHandler
    ) {
        self.stateMachine = stateMachine
        self.networking = networking
        self.state = stateMachine.state
        self.returnURL = returnURL
        self.merchantIdentifier = merchantIdentifier
        self.merchantName = merchantName
        self.supportedNetworks = supportedNetworks
        self.countryCode = countryCode ?? Self.deviceCountryCode()
        self.paymentResultHandler = paymentResultHandler
    }

    /// True when the device is able to make payments with one of the supported networks.
    static func canMakePayments(
        usingNetworks networks: [PKPaymentNetwork] = defaultSupportedNetworks
    ) -> Bool {
        PKPaymentAuthorizationController.canMakePayments(usingNetworks: networks)
    }

    func initialize() async {
        if Self.canMakePayments(usingNetworks: supportedNetworks) {
            await transition(.initialize)
        } else {
            Self.logger.debug("apple pay is not available on this device")
            await transition(.applePayUnavailable)
        }
    }

    func transition(_ event: ApplePayStatechart.Event) async {
        Self.logger.trace("handling event: \(String(describing: event.hashableIdentifier))")

        let result = try? self.stateMachine.transition(event)

        if let result {
            if result.toState.hashableIdentifier == .errored {
                self.subscription?.cancel()
            }

            self.state = result.toState
            Self.logger.trace("new state: \(String(describing: self.state.hashableIdentifier))")
        }

        if let sideEffect = result?.sideEffect {
            await handleSideEffect(sideEffect: sideEffect)
        }
    }

    private func handleSideEffect(sideEffect: ApplePayStatechart.SideEffect) async {
        switch sideEffect {

        case .createPaymentRequest:
            Self.logger.debug("creating apple pay payment request")

            let result = await networking.createPaymentRequest(returnURL: self.returnURL)

            // The component's task is cancelled when the view disappears; don't
            // treat that as a payment error. A repeated initialize retries the
            // request creation when the view appears again.
            if Task.isCancelled {
                return
            }

            switch result {

            case .failure(let error):
                Self.logger.error("error creating apple pay payment request: \(error)")
                await handleError(error: error)

            case .success(let payment):
                guard payment.gateway == .case(.kronor), let cdeToken = payment.authToken else {
                    Self.logger.error("apple pay payment is missing the gateway configuration")
                    await handleError(error: .usageError(error: .empty))
                    return
                }

                self.cdeToken = cdeToken
                await transition(.paymentRequestCreated(waitToken: payment.waitToken))
            }

        case .subscribeToPaymentStatus(let waitToken):
            await subscribeToPaymentStatus(waitToken: waitToken)

        case .presentPaymentSheet:
            await presentPaymentSheet()

        case .notifyPaymentSuccess:
            Self.logger.trace("performing notifyPaymentSuccess")
            self.subscription?.cancel()
            if let paymentId = self.paymentRequest?.resultingPaymentId {
                await self.paymentResultHandler(.success(paymentId))
            } else {
                Self.logger.error("could not find resultingPaymentId before calling onPaymentSuccess")
            }

        case .cancelAndNotifyFailure:
            Self.logger.trace("performing cancelAndNotifyFailure")
            self.subscription?.cancel()
            let _ = await networking.cancelSessionPayments()
            await self.paymentResultHandler(.failure(.cancelled))

        case .resetState:
            self.subscription?.cancel()
            self.subscription = nil

            if let _ = self.paymentRequest {
                let _ = await networking.cancelSessionPayments()
            }

            self.paymentRequest = nil
            self.cdeToken = nil
            await transition(.initialize)
        }
    }

    private func presentPaymentSheet() async {
        guard let paymentRequest = self.paymentRequest, let cdeToken = self.cdeToken else {
            Self.logger.error("attempted to present the payment sheet without a payment request")
            await handleError(error: .usageError(error: .empty))
            return
        }

        let request = PKPaymentRequest()
        request.merchantIdentifier = merchantIdentifier
        request.merchantCapabilities = .capability3DS
        request.supportedNetworks = supportedNetworks
        request.countryCode = countryCode
        request.currencyCode = paymentRequest.currency.rawValue
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(
                label: merchantName,
                amount: NSDecimalNumber(string: paymentRequest.amount).multiplying(byPowerOf10: -2)
            )
        ]

        let delegate = ApplePaySessionDelegate(
            onAuthorize: { [weak self] payment in
                await self?.authorizePayment(payment: payment, cdeToken: cdeToken) ?? false
            },
            onFinish: { [weak self] outcome in
                await self?.handleSheetOutcome(outcome)
            }
        )

        let controller = PKPaymentAuthorizationController(paymentRequest: request)
        controller.delegate = delegate
        self.session = (controller: controller, delegate: delegate)

        let presented = await controller.present()
        if !presented {
            Self.logger.error("could not present the apple pay payment sheet")
            self.session = nil
            await transition(.sheetDismissed)
        }
    }

    private func authorizePayment(payment: AuthorizedApplePayPayment, cdeToken: String) async -> Bool {
        let tokenInput: KronorCdeApi.ApplePayPaymentTokenInput
        do {
            tokenInput = try payment.tokenInput()
        } catch {
            Self.logger.error("could not decode the apple pay payment token: \(error)")
            return false
        }

        let result = await networking.authorizePayment(cdeToken: cdeToken, token: tokenInput)

        switch result {
        case .failure(let error):
            Self.logger.error("error authorizing the apple pay payment: \(error)")
            return false

        case .success(let authorization):
            switch authorization.status.value {
            case .success:
                return true
            default:
                Self.logger.error("apple pay payment was not authorized: \(authorization.status.rawValue)")
                return false
            }
        }
    }

    private func handleSheetOutcome(_ outcome: ApplePaySheetOutcome) async {
        self.session = nil

        switch outcome {
        case .authorized:
            await transition(.tokenAuthorized)
        case .rejected:
            await transition(.paymentRejected)
        case .dismissed:
            await transition(.sheetDismissed)
        }
    }

    private func handleError(error: KronorApi.KronorError) async {
        let _ = await transition(.error(error: error))
    }

    private func subscribeToPaymentStatus(waitToken: String) async {
        self.subscription?.cancel()
        let stream = await networking.subscribeToPaymentStatus()
        self.subscription = Task { [weak self] in
            for await (result, apiError) in stream {
                guard !Task.isCancelled, let self else { return }

                switch result {
                case .failure(let error):
                    await self.handleError(error: .networkError(error: error))

                case .success(let paymentRequests):
                    let request = paymentRequests
                        .first(where: { paymentRequest in
                            paymentRequest.waitToken == waitToken &&

                            (paymentRequest.status?.contains { status in
                                status.status != KronorApi.PaymentStatusEnum.initializing
                            } ?? false)
                        })

                    if let request {
                        self.paymentRequest = request

                        if case .waitingForPaymentRequest = self.stateMachine.state {
                            await self.transition(.paymentRequestInitialized)
                        }

                        let wasAuthorized = request.status?.contains { status in
                            [KronorApi.PaymentStatusEnum.paid, KronorApi.PaymentStatusEnum.authorized, KronorApi.PaymentStatusEnum.flowCompleted].contains {
                                $0 == status.status.value
                            }
                        }

                        if wasAuthorized ?? false {
                            await self.transition(.paymentAuthorized)
                        }

                        let wasRejected = request.status?.contains { status in
                            [KronorApi.PaymentStatusEnum.error, KronorApi.PaymentStatusEnum.declined, KronorApi.PaymentStatusEnum.cancelled].contains {
                                $0 == status.status.value
                            }
                        }

                        if wasRejected ?? false {
                            await self.transition(.paymentRejected)
                        }
                    }

                    if let error = apiError {
                        await self.handleError(
                            error: .usageError(error: error)
                        )
                    }
                }
            }
        }
    }

    private static func deviceCountryCode() -> String {
        let code: String?
        if #available(iOS 16, *) {
            code = Locale.current.region?.identifier
        } else {
            code = Locale.current.regionCode
        }
        return code ?? "SE"
    }

    isolated deinit {
        switch self.state {
        case .creatingPaymentRequest, .waitingForPaymentRequest, .paymentReady, .authorizing, .waitingForPayment:
            Task { [networking] in
                Self.logger.debug("[deinit] cancelling payment request")
                let _ = await networking.cancelSessionPayments()
            }
        default:
            break
        }
        self.subscription?.cancel()
    }
}

extension ApplePayPaymentViewModel: RetryableModel {
    func cancel() async {
        await self.transition(.cancelFlow)
    }

    func retry() async {
        await self.transition(.retry)
    }
}
