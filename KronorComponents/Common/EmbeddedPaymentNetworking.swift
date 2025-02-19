//
//  EmbeddedPaymentNetworking.swift
//  
//
//  Created by Niclas Heltoft on 17/07/2023.
//

import Foundation
import Kronor
import KronorApi

protocol EmbeddedPaymentNetworking: PaymentNetworking {
    func createMobilePayPaymentRequest(
        returnURL: URL
    ) async -> Result<String, KronorApi.KronorError>

    func createCreditCardPaymentRequest(
        returnURL: URL
    ) async -> Result<String, KronorApi.KronorError>
    
    func createVippsRequest(
        returnURL: URL
    ) async -> Result<String, KronorApi.KronorError>
    
    func createPayPalRequest(
        returnURL: URL,
        merchantReturnURL: URL
    ) async -> Result<String, KronorApi.KronorError>
}
