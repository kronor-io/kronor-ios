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

/// Asked whenever the status channel has burned through its failure budget.
/// Answering `true` keeps the channel alive instead of surfacing the failure,
/// which is what the flow wants while the customer is on the payment site: the
/// payment is proceeding there whether or not we can currently observe it.
typealias KeepRetrying = @Sendable () async -> Bool

protocol PaymentNetworking: Sendable {
    func subscribeToPaymentStatus(
        onRetry: RetryNotification?,
        keepRetrying: KeepRetrying?
    ) async -> AsyncStream<PaymentStatusUpdate>

    func cancelSessionPayments() async -> Result<(), Never>

    func refreshPaymentStatus() async -> Result<Bool, KronorApi.KronorError>
}

extension PaymentNetworking {
    func subscribeToPaymentStatus() async -> AsyncStream<PaymentStatusUpdate> {
        await subscribeToPaymentStatus(onRetry: nil, keepRetrying: nil)
    }

    func subscribeToPaymentStatus(onRetry: RetryNotification?) async -> AsyncStream<PaymentStatusUpdate> {
        await subscribeToPaymentStatus(onRetry: onRetry, keepRetrying: nil)
    }
}
