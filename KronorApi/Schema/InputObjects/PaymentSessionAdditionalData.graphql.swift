// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension KronorApi {
  /// Arguments for adding additional data to a payment.
  struct PaymentSessionAdditionalData: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      email: String,
      ip: String,
      language: GraphQLEnum<Language>,
      name: String,
      phoneNumber: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "email": email,
        "ip": ip,
        "language": language,
        "name": name,
        "phoneNumber": phoneNumber
      ])
    }

    /// The E-mail address of the customer.
    public var email: String {
      get { __data["email"] }
      set { __data["email"] = newValue }
    }

    /// IP address of the customer attempting the payment.
    public var ip: String {
      get { __data["ip"] }
      set { __data["ip"] = newValue }
    }

    /// Language in which the payment is being handled
    /// Only languages in two-letter `ISO-639-1` format are recognized.
    /// Example: `SV`, `DA`, `NO`, `IS`, `EN`.
    public var language: GraphQLEnum<Language> {
      get { __data["language"] }
      set { __data["language"] = newValue }
    }

    /// The name of the customer that the payment is associated with.
    ///
    /// Max length: 100.
    public var name: String {
      get { __data["name"] }
      set { __data["name"] = newValue }
    }

    /// Phone number
    /// Max length: 100.
    public var phoneNumber: GraphQLNullable<String> {
      get { __data["phoneNumber"] }
      set { __data["phoneNumber"] = newValue }
    }
  }

}