//
//  PaymentResultHandler.swift
//  Kronor
//
//  Created by Niclas Heltoft on 09/03/2026.
//

/// A closure that handles the outcome of a payment flow.
public typealias PaymentResultHandler = @Sendable (PaymentResult) async -> Void
