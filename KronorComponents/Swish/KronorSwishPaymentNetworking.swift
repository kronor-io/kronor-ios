//
//  KronorSwishPaymentNetworking.swift
//  
//
//  Created by Niclas Heltoft on 17/07/2023.
//

import Foundation
import Kronor
import KronorApi

final class KronorSwishPaymentNetworking: KronorPaymentNetworking, SwishPaymentNetworking {
    func createMcomPaymentRequest(
        returnURL: URL,
        device: Kronor.Device?
    ) async -> Result<String, KronorApi.KronorError> {
        let input = KronorApi.SwishPaymentInput(
            flow: "mcom",
            idempotencyKey: UUID().uuidString,
            returnUrl: returnURL.absoluteString
        )

        var deviceInfo = device.map(makeDeviceInfo)
        if deviceInfo == nil {
            let def = await Kronor.detectDevice()
            deviceInfo = makeDeviceInfo(device: def)
        }

        return await KronorApi.createSwishPaymentRequest(
            client: client,
            input: input,
            deviceInfo: deviceInfo!
        )
    }

    func createEcomPaymentRequest(
        phoneNumber: String,
        returnURL: URL,
        device: Kronor.Device?
    ) async -> Result<String, KronorApi.KronorError> {
        let input = KronorApi.SwishPaymentInput(
            customerSwishNumber: .some(phoneNumber),
            flow: "ecom",
            idempotencyKey: UUID().uuidString,
            returnUrl: returnURL.absoluteString
        )

        var deviceInfo = device.map(makeDeviceInfo)
        if deviceInfo == nil {
            let def = await Kronor.detectDevice()
            deviceInfo = makeDeviceInfo(device: def)
        }

        return await KronorApi.createSwishPaymentRequest(
            client: client,
            input: input,
            deviceInfo: deviceInfo!
        )
    }
}
