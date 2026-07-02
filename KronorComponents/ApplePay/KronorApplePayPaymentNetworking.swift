//
//  KronorApplePayPaymentNetworking.swift
//  kronor-ios
//

import Foundation
import Kronor
import KronorApi
import KronorCdeApi

final class KronorApplePayPaymentNetworking: KronorPaymentNetworking, ApplePayPaymentNetworking, @unchecked Sendable {
    func createPaymentRequest(
        returnURL: URL
    ) async -> Result<KronorApi.ApplePayPaymentMutation.Data.NewApplePayPayment, KronorApi.KronorError> {
        let input = KronorApi.ApplePayPaymentInput(
            flow: "mcom",
            idempotencyKey: UUID().uuidString,
            returnUrl: returnURL.absoluteString
        )

        return await KronorApi.createApplePayPaymentRequest(
            client: client,
            input: input,
            deviceInfo: deviceInfo
        )
    }

    func authorizePayment(
        cdeToken: String,
        token: KronorCdeApi.ApplePayPaymentTokenInput
    ) async -> Result<KronorCdeApi.AuthorizeApplePayPaymentMutation.Data.AuthorizeApplePayPayment, KronorCdeApi.CdeError> {
        let client = KronorCdeApi.makeGraphQLClient(env: env, token: cdeToken)
        return await KronorCdeApi.authorizeApplePayPayment(client: client, token: token)
    }
}
