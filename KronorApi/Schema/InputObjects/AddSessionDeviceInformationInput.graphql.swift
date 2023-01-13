// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension KronorApi {
  /// Aguments for adding device information on a device related to a payment session.
  struct AddSessionDeviceInformationInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      browserName: String,
      browserVersion: String,
      fingerprint: String,
      osName: String,
      osVersion: String,
      userAgent: String
    ) {
      __data = InputDict([
        "browserName": browserName,
        "browserVersion": browserVersion,
        "fingerprint": fingerprint,
        "osName": osName,
        "osVersion": osVersion,
        "userAgent": userAgent
      ])
    }

    /// The customer device browser name.
    ///
    /// Max length: 64.
    public var browserName: String {
      get { __data["browserName"] }
      set { __data["browserName"] = newValue }
    }

    /// The customer device browser version.
    ///
    /// Max length: 64.
    public var browserVersion: String {
      get { __data["browserVersion"] }
      set { __data["browserVersion"] = newValue }
    }

    /// The customer device fingerprint.
    ///
    /// Max length: 64.
    public var fingerprint: String {
      get { __data["fingerprint"] }
      set { __data["fingerprint"] = newValue }
    }

    /// The customer device os name.
    ///
    /// Max length: 64.
    public var osName: String {
      get { __data["osName"] }
      set { __data["osName"] = newValue }
    }

    /// The customer device os version.
    ///
    /// Max length: 64.
    public var osVersion: String {
      get { __data["osVersion"] }
      set { __data["osVersion"] = newValue }
    }

    /// The customer device User-Agent string.
    ///
    /// Max length: 512.
    public var userAgent: String {
      get { __data["userAgent"] }
      set { __data["userAgent"] = newValue }
    }
  }

}