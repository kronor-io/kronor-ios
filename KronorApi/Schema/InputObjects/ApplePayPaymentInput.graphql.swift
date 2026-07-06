// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension KronorApi {
  /// Arguments for creating a new apple pay payment
  nonisolated struct ApplePayPaymentInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      flow: String,
      idempotencyKey: String,
      merchantReturnUrl: GraphQLNullable<String> = nil,
      returnUrl: String
    ) {
      __data = InputDict([
        "flow": flow,
        "idempotencyKey": idempotencyKey,
        "merchantReturnUrl": merchantReturnUrl,
        "returnUrl": returnUrl
      ])
    }

    /// Payment flow, either 'ecom' or 'mcom'.
    /// This determines if the flow is apple pay on the web flow or apple pay on the ios app.
    public var flow: String {
      get { __data["flow"] }
      set { __data["flow"] = newValue }
    }

    /// Idempotency key is required to prevent double processing a request.
    /// It is recommended to use a deterministic unique value, such as the combination of
    /// the order id and the customer id. Avoid using time-based values.
    /// Only alphanumeric character and the following are allowed:
    /// - "-"
    /// - "_"
    /// - "."
    /// - ","
    /// - "["
    /// - "]"
    /// - "+"
    ///
    /// Max length: 64.
    public var idempotencyKey: String {
      get { __data["idempotencyKey"] }
      set { __data["idempotencyKey"] = newValue }
    }

    /// The original return url as provided by the merchant.
    public var merchantReturnUrl: GraphQLNullable<String> {
      get { __data["merchantReturnUrl"] }
      set { __data["merchantReturnUrl"] = newValue }
    }

    /// The url to return to after the payment is done. If the payment
    /// screen is opened on a separate window, customer will be redirected
    /// here on payment success or error.
    public var returnUrl: String {
      get { __data["returnUrl"] }
      set { __data["returnUrl"] = newValue }
    }
  }

}