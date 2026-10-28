//
//  ApplePayPaymentNetworking.swift
//  kronor-ios
//

import Foundation
import Kronor
import KronorApi
import KronorCdeApi

typealias ApplePayOrderLine = KronorApi.PaymentSessionOrderLinesQuery.Data.PaymentSession.OrderLine

protocol ApplePayPaymentNetworking: PaymentNetworking {
    func createPaymentRequest(
        returnURL: URL,
        idempotencyKey: String,
        onRetry: RetryNotification?
    ) async -> Result<KronorApi.ApplePayPaymentMutation.Data.NewApplePayPayment, KronorApi.KronorError>

    /// The purchase items the merchant supplied with the payment session.
    func fetchOrderLines() async -> Result<[ApplePayOrderLine], KronorApi.KronorError>

    func authorizePayment(
        cdeToken: String,
        token: KronorCdeApi.ApplePayPaymentTokenInput
    ) async -> Result<KronorCdeApi.AuthorizeApplePayPaymentMutation.Data.AuthorizeApplePayPayment, KronorCdeApi.CdeError>
}
