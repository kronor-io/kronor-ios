//
//  EmbeddedPaymentViewModel.swift
//  
//
//  Created by lorenzo on 2023-01-18.
//

import Foundation
import Kronor
import KronorApi
import os

enum SupportedEmbeddedMethod {
    case mobilePay
    case creditCard
    case vipps
    case payPal
    case bankTransfer
    case p24
    case pointsPay
    case fallback(name: String)
    
    func getName() -> String {
        switch self {
        case .creditCard:
            return "creditCard"
        case .mobilePay:
            return "mobilePay"
        case .vipps:
            return "vipps"
        case .payPal:
            return "paypal"
        case .bankTransfer:
            return "bankTransfer"
        case .p24:
            return "p24"
        case .pointsPay:
            return "pointspay"
        case .fallback(let name):
            return name
        }
    }
    
    func isFallback() -> Bool {
        switch self {
        case .bankTransfer, .p24, .pointsPay, .fallback: return true
        default: return false
        }
    }
}

@MainActor class EmbeddedPaymentViewModel: ObservableObject {

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: EmbeddedPaymentViewModel.self)
    )

    private let stateMachine: EmbeddedPaymentStatechart.EmbeddedPaymentStateMachine
    private let networking: any EmbeddedPaymentNetworking
    private var paymenRequest: KronorApi.PaymentRequestFields?
    private var subscription: Task<Void, Never>?

    private let paymentMethod: SupportedEmbeddedMethod
    private let paymentResultHandler: PaymentResultHandler
    internal let sessionURL: URL
    internal let returnURL: URL
    internal let intermediateRedirectURL: URL
    internal let prefersAuthenticationSession: Bool
    
    @Published var state: EmbeddedPaymentStatechart.State
    @Published var embeddedSiteURL: URL?

    init(
        configuration: ComponentConfiguration,
        stateMachine: EmbeddedPaymentStatechart.EmbeddedPaymentStateMachine,
        networking: some EmbeddedPaymentNetworking,
        paymentMethod: SupportedEmbeddedMethod,
        paymentResultHandler: @escaping PaymentResultHandler,
        prefersAuthenticationSession: Bool = false
    ) {
        self.stateMachine = stateMachine
        self.networking = networking
        self.state = stateMachine.state
        self.paymentResultHandler = paymentResultHandler
        self.paymentMethod = paymentMethod

        let gatewayURL = configuration.env.gatewayURL
        var components = URLComponents()
        components.scheme = gatewayURL.scheme
        components.host = gatewayURL.host
        components.path = "/payment"
        components.queryItems = [
            URLQueryItem(name: "env", value: configuration.env.name),
            URLQueryItem(name: "paymentMethod", value: paymentMethod.getName()),
            URLQueryItem(name: "token", value: configuration.sessionToken),
            URLQueryItem(name: "merchantReturnUrl", value: configuration.returnURL.absoluteString)
        ]

        self.sessionURL = components.url!
        self.returnURL = configuration.returnURL
        self.prefersAuthenticationSession = prefersAuthenticationSession

        components.path = "/" + paymentMethod.getName().lowercased() + "-redirect"
        self.intermediateRedirectURL = components.url!
    }

    func transition(_ event: EmbeddedPaymentStatechart.Event) async {
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
    
    func initialize() async {
        await subscribeToPaymentStatusMatcher(matcher: {_ in true })
    }

    /// Asks the backend to poll the payment provider immediately instead of
    /// waiting on the provider's webhook (which can arrive late) or the next
    /// scheduled poll. Fired when the customer is redirected back to the app
    /// from the external payment app. Failures are only logged: the regular
    /// payment status subscription remains the source of truth.
    func refreshPaymentStatus() {
        Task { [weak self] in
            guard let self else { return }
            Self.logger.debug("refreshing payment status after redirect")
            switch await self.networking.refreshPaymentStatus() {
            case .success(let accepted):
                if !accepted {
                    Self.logger.warning("payment status refresh was not accepted by the backend")
                }
            case .failure(let error):
                Self.logger.warning("could not refresh payment status: \(String(describing: error))")
            }
        }
    }

    private func handleSideEffect(sideEffect: EmbeddedPaymentStatechart.SideEffect) async {
        switch sideEffect {
            
        case .createPaymentRequest:
            
            if self.paymentMethod.isFallback() {
                let _ = await transition(.paymentRequestWillBeCreatedElsewhere)
                return
            }
            
            Self.logger.debug("creating payment request")
            
            let rWaitToken = await {
                switch self.paymentMethod {
                case .mobilePay:
                    return await networking.createMobilePayPaymentRequest(
                        returnURL: self.returnURL
                    )
                case .creditCard:
                    return await networking.createCreditCardPaymentRequest(
                        returnURL: self.returnURL
                    )
                case .vipps:
                    return await networking.createVippsRequest(
                        returnURL: self.returnURL
                    )
                case .payPal:
                    return await networking.createPayPalRequest(
                        returnURL: self.intermediateRedirectURL,
                        merchantReturnURL: self.returnURL
                    )
                case .bankTransfer, .p24, .pointsPay, .fallback:
                    // cannot create the payment request as we don't know how.
                    // it will be created by the web version of the payment gateway
                    fatalError("impossible")
                }
            }()
            
            switch rWaitToken {
                
            case .failure(let error):
                Self.logger.error("error creating payment request: \(error)")
                await handleError(error: error)
            case .success(let waitToken):
                let _ = await transition(.paymentRequestCreated(waitToken: waitToken))
            }


        case .notifyPaymentFailure:
            Self.logger.trace("performing notifyPaymentFailure")
            self.subscription?.cancel()
            await self.paymentResultHandler(.failure(.declined))


        case .cancelAndNotifyFailure:
            Self.logger.trace("performing cancelAndNotifyFailure")
            self.subscription?.cancel()
            await self.paymentResultHandler(.failure(.cancelled))

            
        case .notifyPaymentSuccess:
            Self.logger.trace("performing notifyPaymentSuccess")
            self.subscription?.cancel()
            if let paymentId = self.paymenRequest?.resultingPaymentId {
                await self.paymentResultHandler(.success(paymentId))
            } else {
                Self.logger.error("could not find resultingPaymentId before calling onPaymentSuccess")
            }


        case .subscribeToPaymentStatus(let waitToken):
            await subscribeToPaymentStatus(waitToken: waitToken)
     
        case .openEmbeddedSite:
            self.embeddedSiteURL = self.sessionURL
            Self.logger.info("\(self.sessionURL)")

        case .resetState:
            self.subscription?.cancel()
            self.subscription = nil
            
            if let _ = self.paymenRequest {
                let _ = await networking.cancelSessionPayments()
            }

            self.paymenRequest = nil

            self.embeddedSiteURL = nil

            Task {
                await self.transition(.initialize)
            }

        case .cancelAfterDeadline:
            Self.logger.info("attempting to cancel payment after deadline")
            Task { [weak self] in
                try await Task.sleep(nanoseconds: 1_000_000_000)
                Self.logger.info("firing cancel after deadline")
                await self?.transition(.cancel)
            }
        }
    }

    private func handleError(error: KronorApi.KronorError) async {
        let _ = await transition(.error(error: error))
    }
    
    private func subscribeToPaymentStatus(waitToken: String) async {
        await subscribeToPaymentStatusMatcher(
            matcher: { paymentRequest in
                paymentRequest.waitToken == waitToken
            }
        )
    }

    private func subscribeToPaymentStatusMatcher(matcher: @escaping (KronorApi.PaymentRequestFields) -> Bool) async {
        self.subscription?.cancel()
        let stream = await networking.subscribeToPaymentStatus()
        self.subscription = Task { [weak self] in
            for await (result, _) in stream {
                guard !Task.isCancelled, let self else { return }

                switch result {
                case .failure(let error):
                    await self.handleError(error: .networkError(error: error))

                case .success(let paymentRequests):
                    let request = paymentRequests
                        .sorted(by: { itemA, itemB in
                            itemA.createdAt > itemB.createdAt
                        })
                        .first(where: { paymentRequest in
                            matcher(paymentRequest) &&
                            (paymentRequest.status?.contains { status in
                                status.status != KronorApi.PaymentStatusEnum.initializing
                            } ?? false)
                        })

                    if let request {
                        self.paymenRequest = request

                        if case .waitingForPaymentRequest = self.stateMachine.state {
                            await self.transition(.paymentRequestInitialized)
                        }

                        if (request.status?.contains {
                            $0.status == KronorApi.PaymentStatusEnum.paid
                            || $0.status == KronorApi.PaymentStatusEnum.authorized
                            || $0.status == KronorApi.PaymentStatusEnum.flowCompleted
                        }) ?? false {
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

                        if case .initializing = self.stateMachine.state {
                            await self.transition(.initialize)
                        }

                    } else {
                        await self.transition(.initialize)
                    }
                }
            }
        }
    }
    
    deinit {
        self.subscription?.cancel()
    }
}

extension EmbeddedPaymentViewModel: RetryableModel {
    func cancel() async {
        await self.transition(.cancelFlow)
    }
    
    func retry() async {
        await self.transition(.retry)
    }
}
