// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension KronorApi {
  /// Arguments for creating a new PayPal payment
  struct SupplyPayPalPaymentMethodIdInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      idempotencyKey: String,
      paymentId: String,
      paymentMethodId: String
    ) {
      __data = InputDict([
        "idempotencyKey": idempotencyKey,
        "paymentId": paymentId,
        "paymentMethodId": paymentMethodId
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

    /// The payment id of a PayPal payment, this is obtained when a
    /// payment request is made. As opposed to a payment_reference which
    /// is the same across multiple payment attempts, this is unique
    /// only for each specific payment.
    ///
    /// Max length: 64.
    public var paymentId: String {
      get { __data["paymentId"] }
      set { __data["paymentId"] = newValue }
    }

    /// This is obtained from Braintree when you use their client SDK to
    /// create a payment.
    ///
    /// Max length: 64.
    public var paymentMethodId: String {
      get { __data["paymentMethodId"] }
      set { __data["paymentMethodId"] = newValue }
    }
  }

}