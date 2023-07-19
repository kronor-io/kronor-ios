//
//  PayPalViewModel.swift
//  
//
//  Created by lorenzo on 2023-01-26.
//

import Foundation
import Kronor
import KronorApi
import Apollo
import os
import BraintreeCore
import BraintreePayPal


class PayPalViewModel: ObservableObject {
    
    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: PayPalViewModel.self)
    )

    private let stateMachine: PayPalStatechart.PayPalStateMachine
    private let networking: any PayPalPaymentNetworking
    private var paypalData: KronorApi.PayPalData?
    private var paymenRequest: KronorApi.PaymentStatusSubscription.Data.PaymentRequest?
    private var subscription: Cancellable?

    private var returnURL: URL
    private var device: Kronor.Device?
    private var onPaymentFailure: () -> ()
    private var onPaymentSuccess: (_ paymentId: String) -> ()

    @Published var state: PayPalStatechart.State
    
    init(stateMachine: PayPalStatechart.PayPalStateMachine,
         networking: some PayPalPaymentNetworking,
         returnURL: URL,
         device: Kronor.Device? = nil,
         onPaymentFailure: @escaping () -> (),
         onPaymentSuccess: @escaping (_ paymentId: String) -> ()
    ) {
        self.stateMachine = stateMachine
        self.networking = networking
        self.state = stateMachine.state
        self.device = device
        self.onPaymentSuccess = onPaymentSuccess
        self.onPaymentFailure = onPaymentFailure
        self.returnURL = returnURL
    }

    func transition(_ event: PayPalStatechart.Event) async {
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

    private func handleSideEffect(sideEffect: PayPalStatechart.SideEffect) async {
        switch sideEffect {
            
        case .createPaymentRequest:
            Self.logger.debug("creating payment request")
            
            let paypalResult = await networking.createPayPalPaymentRequest(
                returnURL: self.returnURL,
                device: self.device
            )
            
            switch paypalResult {
            case .failure(let error):
                Self.logger.error("error creating payment request: \(error)")
                await handleError(error: error)
            case .success(let data):
                self.paypalData = data
                let _ = await transition(.paymentRequestCreated)
            }


        case .cancelPaymentRequest:
            Task { [weak self] in
                if let self {
                    Self.logger.notice("cancelling payment request")
                    let _ = await self.networking.cancelSessionPayments()
                }
            }


        case .notifyPaymentFailure:
            Self.logger.trace("performing notifyPaymentFailure")
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


        case .subscribeToPaymentStatus:
            if let waitToken = self.paypalData?.paymentData.paymentId {
                subscribeToPaymentStatus(waitToken: waitToken)
            }
            
        case .resetState:
            self.subscription?.cancel()
            self.subscription = nil
            
            if let _ = self.paymenRequest {
                let _ = await self.networking.cancelSessionPayments()
            }

            self.paymenRequest = nil
            self.paypalData = nil

            Task {
                await self.transition(.initialize)
            }

        case .initializeBraintreeSDK:
            if let data = self.paypalData,
               let amount = Int(data.paymentData.amount) {
                
                let payPalDriver = BTPayPalDriver(apiClient: BTAPIClient(authorization: data.braintreeSettings.tokenizationKey)!)
                let checkoutRequest = BTPayPalCheckoutRequest(amount: String(amount/100))
                checkoutRequest.currencyCode = data.paymentData.currency

                do {
                    let tokenized = try await payPalDriver.tokenizePayPalAccount(with: checkoutRequest)
                    let result = await networking.sendPayPalNonce(input: KronorApi.SupplyPayPalPaymentMethodIdInput(
                        idempotencyKey: UUID().uuidString,
                        paymentId: data.paymentData.paymentId,
                        paymentMethodId: tokenized.nonce
                    ))
                    
                    switch result {
                    case .failure(let error):
                        await self.handleError(error: error)
                    default:
                        await self.transition(.nonceSent)
                    }
                } catch {
                    if error._code == 4 {
                        await self.transition(.cancel)
                    } else {
                        await self.handleError(error: .networkError(error: error))
                    }
                }
            } else {
                Self.logger.error("Could not convert amount to major units: \(String(describing: self.paypalData?.paymentData.amount))")
            }
        }
    }

    private func handleError(error: KronorApi.KronorError) async {
        let _ = await transition(.error(error: error))
    }
    
    private func subscribeToPaymentStatus(waitToken: String) {
        self.subscription = networking.subscribeToPaymentStatus() { [weak self] result in
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
        case .waitingForPayment, .paymentRequestInitialized:
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

extension PayPalViewModel: RetryableModel {
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

func createPayPalPaymentRequest(client: ApolloClient, returnURL: URL, device: Kronor.Device?) async -> Result<KronorApi.PayPalData, KronorApi.KronorError> {
    let input = KronorApi.PayPalPaymentInput(
        idempotencyKey: UUID().uuidString,
        returnUrl: returnURL.absoluteString
    )
    
    var deviceInfo = device.map(makeDeviceInfo)
    if deviceInfo == nil {
        let def = await Kronor.detectDevice()
        deviceInfo = makeDeviceInfo(device: def)
    }

    return await KronorApi.createPayPalPaymentRequest(client: client, input: input, deviceInfo: deviceInfo!)
}
