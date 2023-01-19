// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension KronorApi {
  /// Arguments for creating a new credit card payment
  struct CreditCardPaymentInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      idempotencyKey: String,
      returnUrl: String
    ) {
      __data = InputDict([
        "idempotencyKey": idempotencyKey,
        "returnUrl": returnUrl
      ])
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

    /// The url to return to after the payment is done. If the payment
    /// screen is opened on a separate window, customer will be redirected
    /// here on payment success or error.
    public var returnUrl: String {
      get { __data["returnUrl"] }
      set { __data["returnUrl"] = newValue }
    }
  }

}