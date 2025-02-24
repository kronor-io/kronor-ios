//
//  SwishPaymentNetworking.swift
//  
//
//  Created by Niclas Heltoft on 17/07/2023.
//

import Foundation
import Kronor
import KronorApi

protocol SwishPaymentNetworking: PaymentNetworking {
    func createMcomPaymentRequest(
        returnURL: URL
    ) async -> Result<String, KronorApi.KronorError>

    func createEcomPaymentRequest(
        phoneNumber: String,
        returnURL: URL
    ) async -> Result<String, KronorApi.KronorError>
}
