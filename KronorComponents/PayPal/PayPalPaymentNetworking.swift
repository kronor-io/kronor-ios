//
//  PayPalPaymentNetworking.swift
//  
//
//  Created by Niclas Heltoft on 17/07/2023.
//

import Foundation
import Kronor
import KronorApi

protocol PayPalPaymentNetworking: PaymentNetworking {
    func sendPayPalNonce(
        input: KronorApi.SupplyPayPalPaymentMethodIdInput
    ) async -> Result<(), KronorApi.KronorError>

    func createPayPalPaymentRequest(
        returnURL: URL,
        device: Kronor.Device?
    ) async -> Result<KronorApi.PayPalData, KronorApi.KronorError>
}
