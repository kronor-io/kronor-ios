//
//  SwishPaymentViewModel.swift
//  kronor-ios
//
//  Created by lorenzo on 2023-01-04.
//

import Foundation
import Kronor
import KronorApi
import Apollo
import os

#if canImport(UIKit)
import UIKit
#endif

class SwishPaymentViewModel: ObservableObject {
    
    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: SwishPaymentViewModel.self)
    )

    private let stateMachine: SwishStatechart.SwishStateMachine
    private let networking: any SwishPaymentNetworking
    private var paymenRequest: KronorApi.PaymentStatusSubscription.Data.PaymentRequest?
    private var subscription: Cancellable?

    
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
    
    private var returnURL: URL
    private var device: Kronor.Device?
    private var onPaymentFailure: (_ reason: FailureReason) -> ()
    private var onPaymentSuccess: (_ paymentId: String) -> ()
    
    @Published var state: SwishStatechart.State
    
#if canImport(UIKit)
    @Published var swishAppInstalled = true
#else
    @Published var swishAppInstalled = false
#endif

    init(
        stateMachine: SwishStatechart.SwishStateMachine,
        networking: some SwishPaymentNetworking,
        returnURL: URL,
        device: Kronor.Device? = nil,
        onPaymentFailure: @escaping (_ reason: FailureReason) -> (),
        onPaymentSuccess: @escaping (_ paymentId: String) -> ()
    ) {
        self.stateMachine = stateMachine
        self.networking = networking
        self.state = stateMachine.state
        self.returnURL = returnURL
        self.device = device
        self.onPaymentSuccess = onPaymentSuccess
        self.onPaymentFailure = onPaymentFailure
    }

    func transition(_ event: SwishStatechart.Event) async {
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

    private func handleSideEffect(sideEffect: SwishStatechart.SideEffect) async {
        switch sideEffect {
        
        case .createMcomPaymentRequest:
            Self.logger.debug("creating swish mcom request")

            let rWaitToken = await networking.createMcomPaymentRequest(
                returnURL: self.returnURL,
                device: self.device
            )
            
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
                device: self.device
            )
            
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
            await MainActor.run {
                self.onPaymentFailure(.declined)
            }
        
        case .cancelFlow:
            Self.logger.trace("performing cancelFlow")
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

            
        case .openSwishApp:
#if canImport(UIKit)
            if self.swishAppInstalled {
                await MainActor.run {
                    if let url = self.swishURL {
                        Self.logger.debug("attempting to open \(url)")
                        UIApplication.shared.open(url) { [weak self] success in
                            if success {
                                Task {
                                    await self?.transition(.swishAppOpened)
                                }
                            } else {
                                Self.logger.trace("could not open swish app")
                                self?.swishAppInstalled = false
                                Task {
                                    await self?.transition(.retry)
                                }
                            }
                        }
                    }
                }
            }
#endif
            break


        case .subscribeToPaymentStatus(let waitToken):
            subscribeToPaymentStatus(waitToken: waitToken)
            
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
                    
                    if case .waitingForPaymentRequest(_) = self?.stateMachine.state {
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
                
                if let errors = selectionSet.errors {
                    Task { [weak self] in
                        await self?.handleError(error: .usageError(
                            error: KronorApi.APIError(
                                errors: errors,
                                extensions: selectionSet.extensions ?? [:]
                            )
                        ))
                    }
                }

            }
        }
    }
    
    deinit {
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

func makeDeviceInfo(device: Kronor.Device) -> KronorApi.AddSessionDeviceInformationInput {
    KronorApi.AddSessionDeviceInformationInput(
        browserName: device.appName,
        browserVersion: device.appVersion,
        fingerprint: device.fingerprint,
        osName: device.osName,
        osVersion: device.osVersion,
        userAgent: "\(device.appName)/\(device.appVersion) (\(device.deviceModel))"
    )
}
