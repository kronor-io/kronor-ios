//
//  PaymentNetworking.swift
//  
//
//  Created by Niclas Heltoft on 17/07/2023.
//

import Foundation
import Apollo
import KronorApi

protocol PaymentNetworking {
    func subscribeToPaymentStatus(
        resultHandler: @escaping (Result<KronorApi.PaymentStatusSubscription.Data, Error>, KronorApi.APIError?) -> Void
    ) async -> Cancellable

    func cancelSessionPayments() async -> Result<(), Never>
}
