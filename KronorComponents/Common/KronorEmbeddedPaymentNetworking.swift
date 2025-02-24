//
//  KronorEmbeddedPaymentNetworking.swift
//  
//
//  Created by Niclas Heltoft on 17/07/2023.
//

import Foundation
import Kronor
import KronorApi
import Apollo

final class KronorEmbeddedPaymentNetworking: KronorPaymentNetworking, EmbeddedPaymentNetworking {
    func createMobilePayPaymentRequest(
        returnURL: URL
    ) async -> Result<String, KronorApi.KronorError> {
        let input = KronorApi.MobilePayPaymentInput(
            idempotencyKey: UUID().uuidString,
            returnUrl: returnURL.absoluteString
        )

        return await KronorApi.createMobilePayPaymentRequest(
            client: client,
            input: input,
            deviceInfo: deviceInfo
        )
    }

    func createCreditCardPaymentRequest(
        returnURL: URL
    ) async -> Result<String, KronorApi.KronorError> {
        let input = KronorApi.CreditCardPaymentInput(
            idempotencyKey: UUID().uuidString,
            returnUrl: returnURL.absoluteString
        )

        return await KronorApi.createCreditCardPaymentRequest(
            client: client,
            input: input,
            deviceInfo: deviceInfo
        )
    }

    func createVippsRequest(
        returnURL: URL
    ) async -> Result<String, KronorApi.KronorError> {
        let input = KronorApi.VippsPaymentInput(
            idempotencyKey: UUID().uuidString,
            returnUrl: returnURL.absoluteString
        )

        return await KronorApi.createVippsPaymentRequest(
            client: client,
            input: input,
            deviceInfo: deviceInfo
        )
    }

    func createPayPalRequest(
        returnURL: URL,
        merchantReturnURL: URL
    ) async -> Result<String, KronorApi.KronorError> {
         let input = KronorApi.PayPalPaymentInput(
             idempotencyKey: UUID().uuidString,
             merchantReturnUrl: .some(merchantReturnURL.absoluteString),
             returnUrl: returnURL.absoluteString
         )

         return await KronorApi.createPayPalPaymentRequest(
            client: client,
            input: input,
            deviceInfo: deviceInfo
         )
     }
}
