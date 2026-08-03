//
//  PaymentError.swift
//
//
//  Created by lorenzo on 2023-09-29.
//

/// Represents errors that can occur during a payment flow.
public enum PaymentError: Error {
    /// The payment was cancelled by the user.
    case cancelled
    /// The payment was declined by the payment provider.
    case declined
    /// The payment flow encountered an unexpected error (for example a
    /// network failure) and could not complete. The customer is offered a
    /// retry, so the flow may still recover after this is reported.
    case failed
}
