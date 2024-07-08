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

enum SupportedEmbeddedMethod {
    case mobilePay
    case creditCard
    case vipps
    case payPal
    case bankTransfer
    case p24
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
        case .fallback(let name):
            return name
        }
    }
    
    func isFallback() -> Bool {
        switch self {
        case .bankTransfer, .p24, .fallback: return true
        default: return false
        }
    }
}

class EmbeddedPaymentViewModel: ObservableObject {
    
    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: EmbeddedPaymentViewModel.self)
    )

    private let stateMachine: EmbeddedPaymentStatechart.EmbeddedPaymentStateMachine
    private let networking: any EmbeddedPaymentNetworking
    private var paymenRequest: KronorApi.PaymentStatusSubscription.Data.PaymentRequest?
    private var subscription: Cancellable?

    private var paymentMethod: SupportedEmbeddedMethod
    private var device: Kronor.Device?
    private var onPaymentFailure: (_ reason: FailureReason) -> ()
    private var onPaymentSuccess: (_ paymentId: String) -> ()
    internal let sessionURL: URL
    internal let returnURL: URL
    internal let intermediateRedirectURL: URL
    
    @Published var state: EmbeddedPaymentStatechart.State
    @Published var embeddedSiteURL: URL?

    init(env: Kronor.Environment,
         sessionToken: String,
         stateMachine: EmbeddedPaymentStatechart.EmbeddedPaymentStateMachine,
         networking: some EmbeddedPaymentNetworking,
         paymentMethod: SupportedEmbeddedMethod,
         returnURL: URL,
         device: Kronor.Device? = nil,
         onPaymentFailure: @escaping (_ reason: FailureReason) -> (),
         onPaymentSuccess: @escaping (_ paymentId: String) -> ()
    ) {
        self.stateMachine = stateMachine
        self.networking = networking
        self.state = stateMachine.state
        self.device = device
        self.onPaymentSuccess = onPaymentSuccess
        self.onPaymentFailure = onPaymentFailure
        self.paymentMethod = paymentMethod

        let gatewayURL = env.gatewayURL
        var components = URLComponents()
        components.scheme = gatewayURL.scheme
        components.host = gatewayURL.host
        components.path = "/payment"
        components.queryItems = [
            URLQueryItem(name: "env", value: env.name),
            URLQueryItem(name: "paymentMethod", value: paymentMethod.getName()),
            URLQueryItem(name: "token", value: sessionToken),
            URLQueryItem(name: "merchantReturnUrl", value: returnURL.absoluteString)
        ]

        self.sessionURL = components.url!
        self.returnURL = returnURL
        
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

            await MainActor.run {
                self.state = result.toState
                Self.logger.trace("new state: \(String(describing: self.state.hashableIdentifier))")
            }
        }

        if let sideEffect = result?.sideEffect {
            await handleSideEffect(sideEffect: sideEffect)
        }
    }
    
    func initialize() async {
        subscribeToPaymentStatusMatcher(matcher: {_ in true })
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
                        returnURL: self.returnURL,
                        device: self.device
                    )
                case .creditCard:
                    return await networking.createCreditCardPaymentRequest(
                        returnURL: self.returnURL,
                        device: self.device
                    )
                case .vipps:
                    return await networking.createVippsRequest(
                        returnURL: self.returnURL,
                        device: self.device
                    )
                case .payPal:
                    return await networking.createPayPalRequest(
                        returnURL: self.intermediateRedirectURL,
                        merchantReturnURL: self.returnURL,
                        device: self.device
                    )
                case .bankTransfer, .p24, .fallback:
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
            await MainActor.run {
                self.onPaymentFailure(.declined)
            }


        case .cancelAndNotifyFailure:
            Self.logger.trace("performing cancelAndNotifyFailure")
            self.subscription?.cancel()
            await MainActor.run {
                self.onPaymentFailure(.cancelled)
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
                Self.logger.info("\(self.sessionURL)")
            }

        case .resetState:
            self.subscription?.cancel()
            self.subscription = nil
            
            if let _ = self.paymenRequest {
                let _ = await networking.cancelSessionPayments()
            }

            self.paymenRequest = nil

            await MainActor.run {
                self.embeddedSiteURL = nil
            }

            Task {
                await self.transition(.initialize)
            }

        case .cancelAfterDeadline:
            Self.logger.info("attempting to cancel payment after deadline")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                Task { [weak self] in
                    if let state = self?.state, state == .waitingForPaymentRequest {
                        Self.logger.info("attempting to cancel payment after deadline")
                        await self?.transition(.cancel)
                    }
                }
            }
        }
    }

    private func handleError(error: KronorApi.KronorError) async {
        let _ = await transition(.error(error: error))
    }
    
    private func subscribeToPaymentStatus(waitToken: String) {
        subscribeToPaymentStatusMatcher { paymentRequest in
            paymentRequest.waitToken == waitToken
        }
    }
    
    private func subscribeToPaymentStatusMatcher(matcher: @escaping (KronorApi.PaymentStatusSubscription.Data.PaymentRequest) -> Bool) {
        self.subscription = networking.subscribeToPaymentStatus { [weak self] result in
            switch result {
                
            case .failure(let error):
                Task { [weak self] in
                    await self?.handleError(error: .networkError(error: error))
                }
            case .success(let selectionSet):
                let request = selectionSet.data?.paymentRequests
                    .first(where: { paymentRequest in
                        matcher(paymentRequest) &&
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
                    
                    if (request.status?.contains {
                        $0.status == KronorApi.PaymentStatusEnum.paid
                        || $0.status == KronorApi.PaymentStatusEnum.authorized
                        || $0.status == KronorApi.PaymentStatusEnum.accepted
                        || $0.status == KronorApi.PaymentStatusEnum.flowCompleted
                    }) ?? false {
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
                } else {
                    Task { [weak self] in
                        await self?.transition(.initialize)
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
