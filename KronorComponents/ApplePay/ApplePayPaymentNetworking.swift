//
//  ApplePayPaymentNetworking.swift
//  kronor-ios
//

import Foundation
import Kronor
import KronorApi
import KronorCdeApi

protocol ApplePayPaymentNetworking: PaymentNetworking {
    func createPaymentRequest(
        returnURL: URL,
        idempotencyKey: String
    ) async -> Result<KronorApi.ApplePayPaymentMutation.Data.NewApplePayPayment, KronorApi.KronorError>

    func authorizePayment(
        cdeToken: String,
        token: KronorCdeApi.ApplePayPaymentTokenInput
    ) async -> Result<KronorCdeApi.AuthorizeApplePayPaymentMutation.Data.AuthorizeApplePayPayment, KronorCdeApi.CdeError>
}
