// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension KronorCdeApi {
  /// Arguments for authorizing an Apple Pay payment
  nonisolated struct AuthorizeApplePayPaymentInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      token: ApplePayPaymentTokenInput
    ) {
      __data = InputDict([
        "token": token
      ])
    }

    /// The payment token returned by Apple Pay.
    public var token: ApplePayPaymentTokenInput {
      get { __data["token"] }
      set { __data["token"] = newValue }
    }
  }

}