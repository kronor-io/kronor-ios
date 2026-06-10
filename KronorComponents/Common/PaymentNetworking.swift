//
//  PaymentNetworking.swift
//
//
//  Created by Niclas Heltoft on 17/07/2023.
//

import Foundation
import KronorApi

typealias PaymentStatusUpdate = (result: Result<[KronorApi.PaymentRequestFields], Error>, apiError: KronorApi.APIError?)

protocol PaymentNetworking: Sendable {
    func subscribeToPaymentStatus() async -> AsyncStream<PaymentStatusUpdate>

    func cancelSessionPayments() async -> Result<(), Never>

    func refreshPaymentStatus() async -> Result<Bool, KronorApi.KronorError>
}
