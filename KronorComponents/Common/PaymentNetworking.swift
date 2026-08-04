//
//  PaymentNetworking.swift
//
//
//  Created by Niclas Heltoft on 17/07/2023.
//

import Foundation
import KronorApi

typealias PaymentStatusUpdate = (result: Result<[KronorApi.PaymentRequestFields], Error>, apiError: KronorApi.APIError?)

/// Invoked whenever a request or subscription hit a transient failure and is
/// about to be retried, so the UI can tell the customer things are taking
/// longer than usual.
typealias RetryNotification = @Sendable () async -> Void

protocol PaymentNetworking: Sendable {
    func subscribeToPaymentStatus(onRetry: RetryNotification?) async -> AsyncStream<PaymentStatusUpdate>

    func cancelSessionPayments() async -> Result<(), Never>

    func refreshPaymentStatus() async -> Result<Bool, KronorApi.KronorError>
}

extension PaymentNetworking {
    func subscribeToPaymentStatus() async -> AsyncStream<PaymentStatusUpdate> {
        await subscribeToPaymentStatus(onRetry: nil)
    }
}
