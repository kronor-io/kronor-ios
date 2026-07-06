// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension KronorCdeApi {
  /// Header dictionary for Apple Pay payment data. See https://developer.apple.com/documentation/PassKit/payment-token-format-reference
  nonisolated struct ApplePayPaymentHeaderInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      applicationData: GraphQLNullable<String> = nil,
      ephemeralPublicKey: GraphQLNullable<String> = nil,
      publicKeyHash: GraphQLNullable<String> = nil,
      transactionId: GraphQLNullable<String> = nil,
      wrappedKey: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "applicationData": applicationData,
        "ephemeralPublicKey": ephemeralPublicKey,
        "publicKeyHash": publicKeyHash,
        "transactionId": transactionId,
        "wrappedKey": wrappedKey
      ])
    }

    /// Optional hash of the applicationData property of the original payment request.
    public var applicationData: GraphQLNullable<String> {
      get { __data["applicationData"] }
      set { __data["applicationData"] = newValue }
    }

    /// Ephemeral public key bytes. EC_v1 only.
    public var ephemeralPublicKey: GraphQLNullable<String> {
      get { __data["ephemeralPublicKey"] }
      set { __data["ephemeralPublicKey"] = newValue }
    }

    /// Hash of the X.509 encoded public key bytes of the merchant's certificate.
    public var publicKeyHash: GraphQLNullable<String> {
      get { __data["publicKeyHash"] }
      set { __data["publicKeyHash"] = newValue }
    }

    /// Transaction identifier, generated on the device.
    public var transactionId: GraphQLNullable<String> {
      get { __data["transactionId"] }
      set { __data["transactionId"] = newValue }
    }

    /// The symmetric key wrapped using your RSA public key. RSA_v1 only.
    public var wrappedKey: GraphQLNullable<String> {
      get { __data["wrappedKey"] }
      set { __data["wrappedKey"] = newValue }
    }
  }

}