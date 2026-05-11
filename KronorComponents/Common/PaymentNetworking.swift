//
//  PaymentNetworking.swift
//  
//
//  Created by Niclas Heltoft on 17/07/2023.
//

import Foundation
import KronorApi

protocol PaymentNetworking {
    func subscribeToPaymentStatus(
        resultHandler: @escaping (Result<[KronorApi.PaymentRequestFields], Error>, KronorApi.APIError?) -> Void
    ) async -> Task<Void, Never>

    func cancelSessionPayments() async -> Result<(), Never>
}
