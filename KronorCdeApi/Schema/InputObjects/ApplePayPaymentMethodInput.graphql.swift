// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension KronorCdeApi {
  /// See https://developer.apple.com/documentation/applepayontheweb/applepaypaymentmethod
  nonisolated struct ApplePayPaymentMethodInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      billingContact: GraphQLNullable<ApplePayPaymentContactInput> = nil,
      displayName: GraphQLNullable<String> = nil,
      network: GraphQLNullable<String> = nil,
      paymentPass: GraphQLNullable<ApplePayPaymentPassInput> = nil,
      type: GraphQLNullable<GraphQLEnum<ApplePayPaymentMethodTypeEnum>> = nil
    ) {
      __data = InputDict([
        "billingContact": billingContact,
        "displayName": displayName,
        "network": network,
        "paymentPass": paymentPass,
        "type": type
      ])
    }

    /// The billing contact associated with the card.
    public var billingContact: GraphQLNullable<ApplePayPaymentContactInput> {
      get { __data["billingContact"] }
      set { __data["billingContact"] = newValue }
    }

    /// A string, suitable for display, that describes the card.
    public var displayName: GraphQLNullable<String> {
      get { __data["displayName"] }
      set { __data["displayName"] = newValue }
    }

    /// A string, suitable for display, that is the name of the payment network backing the card.
    public var network: GraphQLNullable<String> {
      get { __data["network"] }
      set { __data["network"] = newValue }
    }

    /// The payment pass object currently selected to complete the payment.
    public var paymentPass: GraphQLNullable<ApplePayPaymentPassInput> {
      get { __data["paymentPass"] }
      set { __data["paymentPass"] = newValue }
    }

    /// The type of card the customer uses to complete the transaction.
    public var type: GraphQLNullable<GraphQLEnum<ApplePayPaymentMethodTypeEnum>> {
      get { __data["type"] }
      set { __data["type"] = newValue }
    }
  }

}