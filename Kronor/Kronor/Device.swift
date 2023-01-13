//
//  Device.swift
//  
//
//  Created by lorenzo on 2023-01-13.
//

import Foundation
import FingerprintJS
import SwiftUI

let  fingerprinter = FingerprinterFactory.getInstance()

public extension Kronor {
    
    struct Device {
        public var fingerprint: String
        public var appName: String
        public var appVersion: String
        public var deviceModel: String
        public var osName: String
        public var osVersion: String
    }
    
    static func detectDevice(appName: String? = nil, appVersion: String? = nil) async -> Device {
        return await Device(
            fingerprint: fingerprinter.getFingerprint() ?? "unknown",
            appName: appName ?? (Bundle.main.infoDictionary?["CFBundleName"] as? String) ?? "unknown",
            appVersion: appVersion ?? (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "unknown",
            deviceModel: UIDevice.current.localizedModel,
            osName: UIDevice.current.systemName,
            osVersion: UIDevice.current.systemVersion
        )
    }
}
