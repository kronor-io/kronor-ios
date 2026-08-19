//
//  SwishPaymentViewModel.swift
//  kronor-ios
//
//  Created by lorenzo on 2023-01-04.
//

import Foundation
import Kronor
import KronorApi
import os

#if canImport(UIKit)
import UIKit
#endif

@MainActor class SwishPaymentViewModel: ObservableObject {

    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: SwishPaymentViewModel.self)
    )

    private let stateMachine: SwishStatechart.SwishStateMachine
    private let networking: any SwishPaymentNetworking
    private var paymenRequest: KronorApi.PaymentRequestFields?
    private var subscription: Task<Void, Never>?

    
    var qrCode: String? {
        self.paymenRequest?.transactionSwishDetails?[0].qrCode
    }
    
    var swishURL: URL? {
        if let raw = self.paymenRequest?.transactionSwishDetails?[0].returnUrl {
           let url = URL(string: raw)
           return url
        }
        return nil
    }
    
    private let returnURL: URL
    private let paymentResultHandler: PaymentResultHandler
    
    @Published var state: SwishStatechart.State
    /// True while the flow is retrying transient failures behind the scenes,
    /// so the UI can tell the customer the payment is taking longer than usual.
    @Published private(set) var isDelayed = false
    
#if canImport(UIKit)
    @Published var swishAppInstalled = true
#else
    @Published var swishAppInstalled = false
#endif

    init(
        stateMachine: SwishStatechart.SwishStateMachine,
        networking: some SwishPaymentNetworking,
        returnURL: URL,
        paymentResultHandler: @escaping PaymentResultHandler
    ) {
        self.stateMachine = stateMachine
        self.networking = networking
        self.state = stateMachine.state
        self.returnURL = returnURL
        self.paymentResultHandler = paymentResultHandler
    }

    func transition(_ event: SwishStatechart.Event) async {
        Self.logger.trace("handling event: \(String(describing: event.hashableIdentifier))")

        let result = try? self.stateMachine.transition(event)

        if let result {
            let becameErrored = result.toState.hashableIdentifier == .errored
                && result.fromState.hashableIdentifier != .errored

            if becameErrored {
                self.subscription?.cancel()
            }

            if becameErrored {
                // The customer is offered a retry from the error screen, so the
                // flow is not over yet. The merchant app is only told once the
                // customer gives up; reporting a result here would end the
                // payment as far as the host app is concerned while the SDK
                // keeps driving it.
                self.isDelayed = false
            }

            self.state = result.toState
            Self.logger.trace("new state: \(String(describing: self.state.hashableIdentifier))")
        }

        if let sideEffect = result?.sideEffect {
            await handleSideEffect(sideEffect: sideEffect)
        }
    }

    private func handleSideEffect(sideEffect: SwishStatechart.SideEffect) async {
        switch sideEffect {
        
        case .createMcomPaymentRequest:
            Self.logger.debug("creating swish mcom request")

            let rWaitToken = await networking.createMcomPaymentRequest(
                returnURL: self.returnURL,
                onRetry: self.retryNotification
            )
            self.isDelayed = false
            
            switch rWaitToken {
                
            case .failure(let error):
                Self.logger.error("error creating swish mcom request: \(error)")
                await handleError(error: error)
            case .success(let waitToken):
                let _ = await transition(.paymentRequestCreated(waitToken: waitToken))
            }

            
        case let .createEcomPaymentRequest(phoneNumber):
            Self.logger.debug("creating swish ecom request")
            let rWaitToken = await networking.createEcomPaymentRequest(
                phoneNumber: phoneNumber,
                returnURL: self.returnURL,
                onRetry: self.retryNotification
            )
            self.isDelayed = false
            
            switch rWaitToken {

            case .failure(let error):
                Self.logger.error("error creating swish ecom request: \(error)")
                await handleError(error: error)
            case .success(let waitToken):
                let _ = await transition(.paymentRequestCreated(waitToken: waitToken))
            }


        case .notifyPaymentFailure:
            Self.logger.trace("performing notifyPaymentFailure")
            self.subscription?.cancel()
            await self.paymentResultHandler(.failure(.declined))
        
        case .cancelFlow:
            Self.logger.trace("performing cancelFlow")
            self.subscription?.cancel()
            await self.paymentResultHandler(.failure(.cancelled))


        case .cancelAndNotifyError:
            Self.logger.trace("performing cancelAndNotifyError")
            self.subscription?.cancel()
            await self.paymentResultHandler(.failure(.failed))

            
        case .notifyPaymentSuccess:
            Self.logger.trace("performing notifyPaymentSuccess")
            self.subscription?.cancel()
            if let paymentId = self.paymenRequest?.resultingPaymentId {
                await self.paymentResultHandler(.success(paymentId))
            } else {
                Self.logger.error("could not find resultingPaymentId before calling onPaymentSuccess")
            }

            
        case .openSwishApp:
#if canImport(UIKit)
            if self.swishAppInstalled, let url = self.swishURL {
                Self.logger.debug("attempting to open \(url)")
                let success = await UIApplication.shared.open(url)
                if success {
                    await transition(.swishAppOpened)
                } else {
                    Self.logger.trace("could not open swish app")
                    self.swishAppInstalled = false
                    await transition(.retry)
                }
            }
#endif
            break


        case .subscribeToPaymentStatus(let waitToken):
            await subscribeToPaymentStatus(waitToken: waitToken)
            
        case .resetState:
            self.subscription?.cancel()
            self.subscription = nil
            
            if let _ = self.paymenRequest {
                let _ = await networking.cancelSessionPayments()
            }

            self.paymenRequest = nil
        }
    }
    
    private func handleError(error: KronorApi.KronorError) async {
        let _ = await transition(.error(error: error))
    }

    private var retryNotification: RetryNotification {
        { [weak self] in await self?.noteRetry() }
    }

    private func noteRetry() {
        self.isDelayed = true
    }

    
    private func subscribeToPaymentStatus(waitToken: String) async {
        self.subscription?.cancel()
        let stream = await networking.subscribeToPaymentStatus(onRetry: self.retryNotification)
        self.subscription = Task { [weak self] in
            for await (result, apiError) in stream {
                guard !Task.isCancelled, let self else { return }

                switch result {
                case .failure(let error):
                    await self.handleError(error: .networkError(error: error))

                case .success(let paymentRequests):
                    self.isDelayed = false
                    let request = paymentRequests
                        .first(where: { paymentRequest in
                            paymentRequest.waitToken == waitToken &&

                            (paymentRequest.status?.contains { status in
                                status.status != KronorApi.PaymentStatusEnum.initializing
                            } ?? false)
                        })

                    if let request {
                        self.paymenRequest = request

                        if case .waitingForPaymentRequest(_) = self.stateMachine.state {
                            await self.transition(.paymentRequestInitialized)
                        }

                        if (request.status?.contains { $0.status == KronorApi.PaymentStatusEnum.paid || $0.status == KronorApi.PaymentStatusEnum.authorized }) ?? false {
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

                    // An error alongside a successful response is not fatal:
                    // the subscription keeps delivering updates, so keep
                    // observing instead of stranding the customer on an
                    // error screen.
                    if let error = apiError {
                        Self.logger.warning("payment status update carried an error: \(String(describing: error))")
                    }
                }
            }
        }
    }
    
    isolated deinit {
        switch self.state {
        case .waitingForPayment, .paymentRequestInitialized(_), .creatingPaymentRequest(_), .waitingForPaymentRequest(_):
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

extension SwishPaymentViewModel: RetryableModel {
    func cancel() async {
        await self.transition(.cancelFlow)
    }
    
    func retry() async {
        await self.transition(.retry)
    }
}
