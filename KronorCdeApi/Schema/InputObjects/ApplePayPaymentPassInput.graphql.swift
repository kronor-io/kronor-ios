// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension KronorCdeApi {
  /// See https://developer.apple.com/documentation/applepayontheweb/applepaypaymentmethod
  nonisolated struct ApplePayPaymentPassInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      activationState: GraphQLEnum<ApplePayPaymentPassActivationStateEnum>,
      deviceAccountIdentifier: GraphQLNullable<String> = nil,
      deviceAccountNumberSuffix: GraphQLNullable<String> = nil,
      primaryAccountIdentifier: String,
      primaryAccountNumberSuffix: String
    ) {
      __data = InputDict([
        "activationState": activationState,
        "deviceAccountIdentifier": deviceAccountIdentifier,
        "deviceAccountNumberSuffix": deviceAccountNumberSuffix,
        "primaryAccountIdentifier": primaryAccountIdentifier,
        "primaryAccountNumberSuffix": primaryAccountNumberSuffix
      ])
    }

    /// The activation state of the pass.
    public var activationState: GraphQLEnum<ApplePayPaymentPassActivationStateEnum> {
      get { __data["activationState"] }
      set { __data["activationState"] = newValue }
    }

    /// The unique identifier for the device-specific account number.
    public var deviceAccountIdentifier: GraphQLNullable<String> {
      get { __data["deviceAccountIdentifier"] }
      set { __data["deviceAccountIdentifier"] = newValue }
    }

    /// A version of the device account number suitable for display in your UI.
    public var deviceAccountNumberSuffix: GraphQLNullable<String> {
      get { __data["deviceAccountNumberSuffix"] }
      set { __data["deviceAccountNumberSuffix"] = newValue }
    }

    /// The unique identifier for the primary account number for the payment card.
    public var primaryAccountIdentifier: String {
      get { __data["primaryAccountIdentifier"] }
      set { __data["primaryAccountIdentifier"] = newValue }
    }

    /// A version of the primary account number suitable for display in your UI.
    public var primaryAccountNumberSuffix: String {
      get { __data["primaryAccountNumberSuffix"] }
      set { __data["primaryAccountNumberSuffix"] = newValue }
    }
  }

}