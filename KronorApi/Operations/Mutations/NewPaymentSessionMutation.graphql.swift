// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension KronorApi {
  class NewPaymentSessionMutation: GraphQLMutation {
    public static let operationName: String = "NewPaymentSession"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation NewPaymentSession($payment: PaymentSessionInput!) {
          newPaymentSession(payment: $payment) {
            __typename
            token
          }
        }
        """#
      ))

    public var payment: PaymentSessionInput

    public init(payment: PaymentSessionInput) {
      self.payment = payment
    }

    public var __variables: Variables? { ["payment": payment] }

    public struct Data: KronorApi.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { KronorApi.Objects.Mutation_root }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("newPaymentSession", NewPaymentSession.self, arguments: ["payment": .variable("payment")]),
      ] }

      /// Create a new payment session to start a new stand alone payment. The token from the session can be used in subsequent calls for the payment flow.
      public var newPaymentSession: NewPaymentSession { __data["newPaymentSession"] }

      /// NewPaymentSession
      ///
      /// Parent Type: `PaymentSessionResult`
      public struct NewPaymentSession: KronorApi.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { KronorApi.Objects.PaymentSessionResult }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("token", String.self),
        ] }

        /// Once a payment session is initialized, you can use this token to start the payment flow.
        public var token: String { __data["token"] }
      }
    }
  }

}