import Foundation
import Kronor
import KronorApi
import os

class TrustlyPaymentViewModel: ObservableObject {
    
    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: TrustlyPaymentViewModel.self)
    )

    private let stateMachine: EmbeddedPaymentStatechart.EmbeddedPaymentStateMachine
    private let networking: KronorTrustlyPaymentNetworking
    private var paymenRequest: KronorApi.PaymentRequestFields?
    private var subscription: Task<Void, Never>?

    private let returnURL: URL
    private let paymentResultHandler: PaymentResultHandler

    var payURL: URL? {
        if let raw = self.paymenRequest?.transactionBankTransferDetails?.first?.payUrl {
           let url = URL(string: raw)
           return url
        }
        return nil
    }

    @Published var state: EmbeddedPaymentStatechart.State
    @Published var trustlyCheckoutURL: URL?

    init(
        stateMachine: EmbeddedPaymentStatechart.EmbeddedPaymentStateMachine,
        networking: KronorTrustlyPaymentNetworking,
        returnURL: URL,
        paymentResultHandler: @escaping PaymentResultHandler
    ) {
        self.stateMachine = stateMachine
        self.networking = networking
        self.state = stateMachine.state
        self.returnURL = returnURL
        self.paymentResultHandler = paymentResultHandler
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

        case .notifyPaymentFailure:
            Self.logger.trace("performing notifyPaymentFailure")
            self.subscription?.cancel()
            await MainActor.run {
                self.paymentResultHandler(.failure(.declined))
            }
        
        case .notifyPaymentSuccess:
            Self.logger.trace("performing notifyPaymentSuccess")
            self.subscription?.cancel()
            if let paymentId = self.paymenRequest?.resultingPaymentId {
                await MainActor.run {
                    self.paymentResultHandler(.success(paymentId))
                }
            } else {
                Self.logger.error("could not find resultingPaymentId before calling onPaymentSuccess")
            }


        case .subscribeToPaymentStatus(let waitToken):
            await subscribeToPaymentStatus(waitToken: waitToken)
            
        case .resetState:
            self.subscription?.cancel()
            self.subscription = nil
            
            if let _ = self.paymenRequest {
                let _ = await networking.cancelSessionPayments()
            }

            self.paymenRequest = nil
        case .createPaymentRequest:
            let rWaitToken = await  networking.createPaymentRequest(
                returnURL: self.returnURL
            )
            switch rWaitToken {
                
            case .failure(let error):
                Self.logger.error("error creating payment request: \(error)")
                await handleError(error: error)
            case .success(let waitToken):
                let _ = await transition(.paymentRequestCreated(waitToken: waitToken))
            }
        case .openEmbeddedSite:
            if let url = self.payURL {
                await MainActor.run {
                    self.trustlyCheckoutURL = url
                    Self.logger.info("\(url)")
                }
            }
        case .cancelAndNotifyFailure, .cancelAfterDeadline:
            Self.logger.trace("performing cancelAndNotifyFailure")
            self.subscription?.cancel()
            await MainActor.run {
                self.paymentResultHandler(.failure(.cancelled))
            }
        }
    }
    
    private func handleError(error: KronorApi.KronorError) async {
        let _ = await transition(.error(error: error))
    }
    
    private func subscribeToPaymentStatus(waitToken: String) async {
        self.subscription?.cancel()
        self.subscription = await networking.subscribeToPaymentStatus { [weak self] result, apiError in
            switch result {
                
            case .failure(let error):
                Task { [weak self] in
                    await self?.handleError(error: .networkError(error: error))
                }
            case .success(let paymentRequests):
                let request = paymentRequests
                    .sorted(by: { itemA, itemB in
                        itemA.createdAt > itemB.createdAt
                    })
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
                    
                    if (request.status?.contains {
                        $0.status == KronorApi.PaymentStatusEnum.paid
                        || $0.status == KronorApi.PaymentStatusEnum.flowCompleted
                        || $0.status == KronorApi.PaymentStatusEnum.authorized }) ?? false {
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
                
                if let error = apiError {
                    Task { [weak self] in
                        await self?.handleError(
                            error: .usageError(
                                error: error
                            )
                        )
                    }
                }

            }
        }
    }
    
    deinit {
        switch self.state {
        case .waitingForPayment, .waitingForPaymentRequest:
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

extension TrustlyPaymentViewModel: RetryableModel {
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
