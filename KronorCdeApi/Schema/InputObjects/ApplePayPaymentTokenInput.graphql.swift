// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension KronorCdeApi {
  /// Arguments for an apple pay payment. Fields are the ones from the Apple Pay docs. See https://developer.apple.com/documentation/ApplePayontheWeb/ApplePayPaymentToken
  nonisolated struct ApplePayPaymentTokenInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      paymentData: GraphQLNullable<ApplePayPaymentDataInput> = nil,
      paymentMethod: ApplePayPaymentMethodInput,
      transactionIdentifier: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "paymentData": paymentData,
        "paymentMethod": paymentMethod,
        "transactionIdentifier": transactionIdentifier
      ])
    }

    /// An object containing the encrypted payment data.
    public var paymentData: GraphQLNullable<ApplePayPaymentDataInput> {
      get { __data["paymentData"] }
      set { __data["paymentData"] = newValue }
    }

    /// Information about the card used in the transaction.
    public var paymentMethod: ApplePayPaymentMethodInput {
      get { __data["paymentMethod"] }
      set { __data["paymentMethod"] = newValue }
    }

    /// A unique identifier for this payment.
    public var transactionIdentifier: GraphQLNullable<String> {
      get { __data["transactionIdentifier"] }
      set { __data["transactionIdentifier"] = newValue }
    }
  }

}