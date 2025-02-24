//
//  Device+Extension.swift
//  Kronor
//
//  Created by Niclas Heltoft on 15/02/2025.
//

import Kronor
import KronorApi

extension Kronor.Device {
    var deviceInfo: KronorApi.AddSessionDeviceInformationInput {
        .init(
            browserName: appName,
            browserVersion: appVersion,
            fingerprint: fingerprint,
            osName: osName,
            osVersion: osVersion,
            userAgent: "\(appName)/\(appVersion) (\(deviceModel))"
        )
    }
}
