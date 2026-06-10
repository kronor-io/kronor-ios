// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension KronorApi {
  /// Arguments for creating a new direct debit payment
  nonisolated struct BankTransferPaymentInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      aspspId: GraphQLNullable<Bigint> = nil,
      executionDate: GraphQLNullable<String> = nil,
      flow: GraphQLNullable<String> = nil,
      idempotencyKey: String,
      merchantReturnUrl: GraphQLNullable<String> = nil,
      requestRedirectState: GraphQLNullable<String> = nil,
      returnUrl: String
    ) {
      __data = InputDict([
        "aspspId": aspspId,
        "executionDate": executionDate,
        "flow": flow,
        "idempotencyKey": idempotencyKey,
        "merchantReturnUrl": merchantReturnUrl,
        "requestRedirectState": requestRedirectState,
        "returnUrl": returnUrl
      ])
    }

    /// The ID of the ASPSP to use for this payment.
    public var aspspId: GraphQLNullable<Bigint> {
      get { __data["aspspId"] }
      set { __data["aspspId"] = newValue }
    }

    /// A date in yyyy-mm-dd format, nullable, determines the date to execute this payment.
    /// Has to be past today's date, up to 90 days in the future.
    public var executionDate: GraphQLNullable<String> {
      get { __data["executionDate"] }
      set { __data["executionDate"] = newValue }
    }

    /// Payment flow, either 'ecom' or 'mcom'.
    /// This determines if the flow is web flow or app flow for the Bank Transfer payment.
    public var flow: GraphQLNullable<String> {
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

    /// State string passed back as a parameter in the return URL.
    public var requestRedirectState: GraphQLNullable<String> {
      get { __data["requestRedirectState"] }
      set { __data["requestRedirectState"] = newValue }
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