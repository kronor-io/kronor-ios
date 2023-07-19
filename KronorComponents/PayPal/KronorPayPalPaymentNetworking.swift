//
//  KronorPayPalPaymentNetworking.swift
//  
//
//  Created by Niclas Heltoft on 17/07/2023.
//

import Foundation
import Kronor
import KronorApi

final class KronorPayPalPaymentNetworking: KronorPaymentNetworking, PayPalPaymentNetworking {
    func sendPayPalNonce(
        input: KronorApi.SupplyPayPalPaymentMethodIdInput
    ) async -> Result<(), KronorApi.KronorError> {
        await KronorApi.sendPayPalNonce(
            client: client,
            input: input
        )
    }

    func createPayPalPaymentRequest(
        returnURL: URL,
        device: Kronor.Device?
    ) async -> Result<KronorApi.PayPalData, KronorApi.KronorError> {
        let input = KronorApi.PayPalPaymentInput(
            idempotencyKey: UUID().uuidString,
            returnUrl: returnURL.absoluteString
        )

        var deviceInfo = device.map(makeDeviceInfo)
        if deviceInfo == nil {
            let def = await Kronor.detectDevice()
            deviceInfo = makeDeviceInfo(device: def)
        }

        return await KronorApi.createPayPalPaymentRequest(
            client: client,
            input: input,
            deviceInfo: deviceInfo!
        )
    }
}
