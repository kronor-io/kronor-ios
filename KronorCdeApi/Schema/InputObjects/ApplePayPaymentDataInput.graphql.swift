// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension KronorCdeApi {
  /// See https://developer.apple.com/documentation/PassKit/payment-token-format-reference
  nonisolated struct ApplePayPaymentDataInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      data: String,
      header: ApplePayPaymentHeaderInput,
      signature: String,
      version: String
    ) {
      __data = InputDict([
        "data": data,
        "header": header,
        "signature": signature,
        "version": version
      ])
    }

    /// Encrypted payment data. See Payment Data Keys for the decrypted payment data keys and values.
    public var data: String {
      get { __data["data"] }
      set { __data["data"] = newValue }
    }

    /// Additional version-dependent information you use to decrypt and verify the payment.
    public var header: ApplePayPaymentHeaderInput {
      get { __data["header"] }
      set { __data["header"] = newValue }
    }

    /// Signature of the payment and header data. The signature includes the signing certificate, its intermediate CA certificate, and information about the signing algorithm.
    public var signature: String {
      get { __data["signature"] }
      set { __data["signature"] = newValue }
    }

    /// Version information about the payment token. The token uses EC_v1 for ECC-encrypted data and RSA_v1 for RSA-encrypted data.
    public var version: String {
      get { __data["version"] }
      set { __data["version"] = newValue }
    }
  }

}