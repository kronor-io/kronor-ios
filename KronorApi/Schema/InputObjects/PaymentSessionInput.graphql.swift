// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension KronorApi {
  /// Arguments for creating a new payment session.
  struct PaymentSessionInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      additionalData: GraphQLNullable<PaymentSessionAdditionalData> = nil,
      amount: Int,
      currency: GraphQLNullable<GraphQLEnum<SupportedCurrencyEnum>> = nil,
      expiresAt: String,
      idempotencyKey: String,
      merchantReference: String,
      message: String
    ) {
      __data = InputDict([
        "additionalData": additionalData,
        "amount": amount,
        "currency": currency,
        "expiresAt": expiresAt,
        "idempotencyKey": idempotencyKey,
        "merchantReference": merchantReference,
        "message": message
      ])
    }

    /// Additional data about the customer attempting the payment.
    public var additionalData: GraphQLNullable<PaymentSessionAdditionalData> {
      get { __data["additionalData"] }
      set { __data["additionalData"] = newValue }
    }

    /// The amount the customer pays in minor units.
    /// So 100,56 kr would be 10056
    public var amount: Int {
      get { __data["amount"] }
      set { __data["amount"] = newValue }
    }

    /// When `currency` is not set, it defaults to the merchant's default currency.
    ///
    /// When no payment method is available for the given currency, then
    /// `newPaymentSession` fails with an error. Similarly, attempting to
    /// create a payment with a payment method that is not available for
    /// the given currency also results in an error.
    public var currency: GraphQLNullable<GraphQLEnum<SupportedCurrencyEnum>> {
      get { __data["currency"] }
      set { __data["currency"] = newValue }
    }

    /// Session expiry timestamp in ISO8601 format.
    /// E.g. '1970-01-01T00:00:00Z'
    /// Max is 24 hrs from creation of session.
    public var expiresAt: String {
      get { __data["expiresAt"] }
      set { __data["expiresAt"] = newValue }
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

    /// Merchant's own internal reference that may help the
    /// merchant in identifying this payment. These have to
    /// be globally unique but they should be reused for retrying
    /// a payment.
    ///
    /// Max length: 64.
    public var merchantReference: String {
      get { __data["merchantReference"] }
      set { __data["merchantReference"] = newValue }
    }

    /// A message to show to the customer. It could be an order id or a reference.
    /// Only alphanumeric, Swedish characters, and the following are allowed:
    /// - ':'
    /// - ';'
    /// - '.'
    /// - ','
    /// - '?'
    /// - '!'
    /// - '('
    /// - ')'
    /// - '”'
    /// - '"'
    /// - ' '
    ///
    /// Max length: 50.
    public var message: String {
      get { __data["message"] }
      set { __data["message"] = newValue }
    }
  }

}