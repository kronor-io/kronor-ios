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
        returnURL: URL,
        device: Kronor.Device?
    ) async -> Result<String, KronorApi.KronorError> {
        let input = KronorApi.MobilePayPaymentInput(
            idempotencyKey: UUID().uuidString,
            returnUrl: returnURL.absoluteString
        )

        var deviceInfo = device.map(makeDeviceInfo)
        if deviceInfo == nil {
            let def = await Kronor.detectDevice()
            deviceInfo = makeDeviceInfo(device: def)
        }

        return await KronorApi.createMobilePayPaymentRequest(
            client: client,
            input: input,
            deviceInfo: deviceInfo!
        )
    }

    func createCreditCardPaymentRequest(
        returnURL: URL,
        device: Kronor.Device?
    ) async -> Result<String, KronorApi.KronorError> {
        let input = KronorApi.CreditCardPaymentInput(
            idempotencyKey: UUID().uuidString,
            returnUrl: returnURL.absoluteString
        )

        var deviceInfo = device.map(makeDeviceInfo)
        if deviceInfo == nil {
            let def = await Kronor.detectDevice()
            deviceInfo = makeDeviceInfo(device: def)
        }

        return await KronorApi.createCreditCardPaymentRequest(
            client: client,
            input: input,
            deviceInfo: deviceInfo!
        )
    }

    func createVippsRequest(
        returnURL: URL,
        device: Kronor.Device?
    ) async -> Result<String, KronorApi.KronorError> {
        let input = KronorApi.VippsPaymentInput(
            idempotencyKey: UUID().uuidString,
            returnUrl: returnURL.absoluteString
        )

        var deviceInfo = device.map(makeDeviceInfo)
        if deviceInfo == nil {
            let def = await Kronor.detectDevice()
            deviceInfo = makeDeviceInfo(device: def)
        }

        return await KronorApi.createVippsPaymentRequest(
            client: client,
            input: input,
            deviceInfo: deviceInfo!
        )
    }

    func createPayPalRequest(
        returnURL: URL,
        device: Kronor.Device?
    ) async -> Result<String, KronorApi.KronorError> {
         let input = KronorApi.PayPalPaymentInput(
             idempotencyKey: UUID().uuidString,
             returnUrl: returnURL.absoluteString
         )

         var deviceInfo = device.map(makeDeviceInfo)
         if deviceInfo == nil {
             let def = await Kronor.detectDevice()
             deviceInfo = makeDeviceInfo(device: def)
         }

         return await KronorApi.createPayPalPaymentRequest(client: client, input: input, deviceInfo: deviceInfo!)
     }
}
