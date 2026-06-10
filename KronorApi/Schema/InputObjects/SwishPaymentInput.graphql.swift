// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension KronorApi {
  /// Arguments for creating a new swish payment
  nonisolated struct SwishPaymentInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      customerSwishNumber: GraphQLNullable<String> = nil,
      flow: String,
      idempotencyKey: String,
      merchantReturnUrl: GraphQLNullable<String> = nil,
      returnUrl: String
    ) {
      __data = InputDict([
        "customerSwishNumber": customerSwishNumber,
        "flow": flow,
        "idempotencyKey": idempotencyKey,
        "merchantReturnUrl": merchantReturnUrl,
        "returnUrl": returnUrl
      ])
    }

    /// The Swish number of the customer, required for the 'ecom' flow
    public var customerSwishNumber: GraphQLNullable<String> {
      get { __data["customerSwishNumber"] }
      set { __data["customerSwishNumber"] = newValue }
    }

    /// Payment flow, either 'ecom' or 'mcom'
    ///
    /// Max length: 64.
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

    /// The url to return to after the payment is done.
    public var returnUrl: String {
      get { __data["returnUrl"] }
      set { __data["returnUrl"] = newValue }
    }
  }

}