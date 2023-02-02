//
//  EmbeddedPaymentViewModel.swift
//  
//
//  Created by lorenzo on 2023-01-18.
//

import Foundation
import Kronor
import KronorApi
import Apollo
import os

enum SupportedEmbeddedMethod: String {
    case mobilePay
    case creditCard
    case vipps
}

class EmbeddedPaymentViewModel: ObservableObject {
    
    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: EmbeddedPaymentViewModel.self)
    )

    private let stateMachine: EmbeddedPaymentStatechart.EmbeddedPaymentStateMachine
    private var client: ApolloClient
    private var paymenRequest: KronorApi.PaymentStatusSubscription.Data.PaymentRequest?
    private var subscription: Cancellable?

    private var paymentMethod: SupportedEmbeddedMethod
    private var device: Kronor.Device?
    private var onPaymentFailure: () -> ()
    private var onPaymentSuccess: (_ paymentId: String) -> ()
    internal let sessionURL: URL
    internal let returnURL: URL
    
    @Published var state: EmbeddedPaymentStatechart.State
    @Published var embeddedSiteURL: URL?

    init(env: Kronor.Environment,
         sessionToken: String,
         stateMachine: EmbeddedPaymentStatechart.EmbeddedPaymentStateMachine,
         paymentMethod: SupportedEmbeddedMethod,
         returnURL: URL,
         device: Kronor.Device? = nil,
         onPaymentFailure: @escaping () -> (),
         onPaymentSuccess: @escaping (_ paymentId: String) -> ()
    ) {
        self.stateMachine = stateMachine
        self.client = KronorApi.makeGraphQLClient(env: env, token: sessionToken)
        self.state = stateMachine.state
        self.device = device
        self.onPaymentSuccess = onPaymentSuccess
        self.onPaymentFailure = onPaymentFailure
        self.paymentMethod = paymentMethod

        let gatewayURL = Kronor.gatewayURL(env: env)
        var components = URLComponents()
        components.scheme = gatewayURL.scheme
        components.host = gatewayURL.host
        components.path = "/payment"
        components.queryItems = [
            URLQueryItem(name: "env", value: Self.toEnvName(env: env)),
            URLQueryItem(name: "paymentMethod", value: paymentMethod.rawValue),
            URLQueryItem(name: "token", value: sessionToken),
            URLQueryItem(name: "merchantReturnUrl", value: returnURL.absoluteString)
        ]

        self.sessionURL = components.url!
        self.returnURL = returnURL
    }
    
    static func toEnvName(env: Kronor.Environment) -> String {
        switch env {
        case .sandbox:
            return "staging"
        case .production:
            return "prod"
        }
    }

    func transition(_ event: EmbeddedPaymentStatechart.Event) async {
        Self.logger.trace("handling event: \(String(describing: event.hashableIdentifier))")

        let result = try? self.stateMachine.transition(event)

        if let result {
            if result.toState.hashableIdentifier == .errored {
                self.subscription?.cancel()
            }

            await MainActor.run {
                self.state = result.toState
                Self.logger.trace("new state: \(String(describing: self.state.hashableIdentifier))")
            }
        }

        if let sideEffect = result?.sideEffect {
            await handleSideEffect(sideEffect: sideEffect)
        }
    }

    private func handleSideEffect(sideEffect: EmbeddedPaymentStatechart.SideEffect) async {
        switch sideEffect {
            
        case .createPaymentRequest:
            Self.logger.debug("creating payment request")
            
            let rWaitToken = await {
                switch self.paymentMethod {
                case .mobilePay:
                    return await createMobilePayPaymentRequest(client: self.client,
                                                               returnURL: self.returnURL,
                                                               device: self.device)
                case .creditCard:
                    return await createCreditCardPaymentRequest(client: self.client,
                                                               returnURL: self.returnURL,
                                                               device: self.device)
                case .vipps:
                    return await createVippsRequest(client: self.client,
                                                    returnURL: self.returnURL,
                                                    device: self.device)
                }
            }()
            
            switch rWaitToken {
                
            case .failure(let error):
                Self.logger.error("error creating payment request: \(error)")
                await handleError(error: error)
            case .success(let waitToken):
                let _ = await transition(.paymentRequestCreated(waitToken: waitToken))
            }
            
            
        case .cancelPaymentRequest:
            Task { [weak self] in
                if let self {
                    Self.logger.notice("cancelling payment request")
                    let _ = await cancelSessionPayments(client: self.client)
                }
            }


        case .notifyPaymentFailure:
            Self.logger.trace("performing notifyPaymentFailure")
            self.subscription?.cancel()
            await MainActor.run {
                self.onPaymentFailure()
            }


        case .cancelAndNotifyFailure:
            Self.logger.trace("performing cancelAndNotifyFailure")
            Task { [weak self] in
                if let self {
                    Self.logger.notice("cancelling payment request")
                    let _ = await cancelSessionPayments(client: self.client)
                }
            }
            
            self.subscription?.cancel()
            await MainActor.run {
                self.onPaymentFailure()
            }

            
        case .notifyPaymentSuccess:
            Self.logger.trace("performing notifyPaymentSuccess")
            self.subscription?.cancel()
            if let paymentId = self.paymenRequest?.resultingPaymentId {
                await MainActor.run {
                    self.onPaymentSuccess(paymentId)
                }
            } else {
                Self.logger.error("could not find resultingPaymentId before calling onPaymentSuccess")
            }


        case .subscribeToPaymentStatus(let waitToken):
            subscribeToPaymentStatus(waitToken: waitToken)


        case .openEmbeddedSite:
            await MainActor.run {
                self.embeddedSiteURL = self.sessionURL
            }
            
        case .resetState:
            self.subscription?.cancel()
            self.subscription = nil
            
            if let _ = self.paymenRequest {
                let _ = await cancelSessionPayments(client: client)
            }

            self.paymenRequest = nil

            await MainActor.run {
                self.embeddedSiteURL = nil
            }

            Task {
                await self.transition(.initialize)
            }
        }
    }

    private func handleError(error: KronorApi.KronorError) async {
        let _ = await transition(.error(error: error))
    }
    
    private func subscribeToPaymentStatus(waitToken: String) {
        self.subscription = self.client.subscribe(subscription: KronorApi.PaymentStatusSubscription()) { [weak self] result in
            switch result {
                
            case .failure(let error):
                Task { [weak self] in
                    await self?.handleError(error: .networkError(error: error))
                }
            case .success(let selectionSet):
                let request = selectionSet.data?.paymentRequests
                    .first(where: { paymentRequest in
                        paymentRequest.waitToken == waitToken &&
                        
                        (paymentRequest.status?.contains { status in
                            status.status != KronorApi.PaymentStatusEnum.initializing
                        } ?? false)
                    })

                if let request {
                    self?.paymenRequest = request

                    if case .waitingForPaymentRequest = self?.stateMachine.state {
                        Task { [weak self] in
                            await self?.transition(.paymentRequestInitialized)
                        }
                    }
                    
                    if (request.status?.contains { $0.status == KronorApi.PaymentStatusEnum.paid || $0.status == KronorApi.PaymentStatusEnum.authorized }) ?? false {
                        Task { [weak self] in
                            await self?.transition(.paymentAuthorized)
                        }
                    }
                    
                    let wasRejected = request.status?.contains { status in
                        [KronorApi.PaymentStatusEnum.error, KronorApi.PaymentStatusEnum.declined, KronorApi.PaymentStatusEnum.cancelled].contains {
                            $0 == status.status.value
                        }
                    }

                    if wasRejected ?? false {
                        Task { [weak self] in
                            await self?.transition(.paymentRejected)
                        }
                    }
                }
            }
        }
    }
    
    deinit {
        switch self.state {
        case .waitingForPayment, .paymentRequestInitialized, .creatingPaymentRequest, .waitingForPaymentRequest:
            Task { [weak self] in
                if let self {
                    Self.logger.debug("[deinit] cancelling payment request")
                    let _ = await cancelSessionPayments(client: self.client)
                }
            }
        default:
            break
        }
        self.subscription?.cancel()
    }
}

extension EmbeddedPaymentViewModel: RetryableModel {
    func cancel() {
        Task {
            await self.transition(.cancelFlow)
        }
    }
    
    func retry() {
        Task {
            await self.transition(.retry)
        }
    }
}

func createMobilePayPaymentRequest(client: ApolloClient, returnURL: URL, device: Kronor.Device?) async -> Result<String, KronorApi.KronorError> {
    let input = KronorApi.MobilePayPaymentInput(
        idempotencyKey: UUID().uuidString,
        returnUrl: returnURL.absoluteString
    )
    
    var deviceInfo = device.map(makeDeviceInfo)
    if deviceInfo == nil {
        let def = await Kronor.detectDevice()
        deviceInfo = makeDeviceInfo(device: def)
    }

    return await KronorApi.createMobilePayPaymentRequest(client: client, input: input, deviceInfo: deviceInfo!)
}

func createCreditCardPaymentRequest(client: ApolloClient, returnURL: URL, device: Kronor.Device?) async -> Result<String, KronorApi.KronorError> {
    let input = KronorApi.CreditCardPaymentInput(
        idempotencyKey: UUID().uuidString,
        returnUrl: returnURL.absoluteString
    )
    
    var deviceInfo = device.map(makeDeviceInfo)
    if deviceInfo == nil {
        let def = await Kronor.detectDevice()
        deviceInfo = makeDeviceInfo(device: def)
    }

    return await KronorApi.createCreditCardPaymentRequest(client: client, input: input, deviceInfo: deviceInfo!)
}

func createVippsRequest(client: ApolloClient, returnURL: URL, device: Kronor.Device?) async -> Result<String, KronorApi.KronorError> {
    let input = KronorApi.CreditCardPaymentInput(
        idempotencyKey: UUID().uuidString,
        returnUrl: returnURL.absoluteString
    )
    
    var deviceInfo = device.map(makeDeviceInfo)
    if deviceInfo == nil {
        let def = await Kronor.detectDevice()
        deviceInfo = makeDeviceInfo(device: def)
    }

    return await KronorApi.createCreditCardPaymentRequest(client: client, input: input, deviceInfo: deviceInfo!)
}
