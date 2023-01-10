// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension KronorApi {
  class SwishPaymentMutation: GraphQLMutation {
    public static let operationName: String = "SwishPayment"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation SwishPayment($payment: SwishPaymentInput!) {
          newSwishPayment(pay: $payment) {
            __typename
            waitToken
          }
        }
        """#
      ))

    public var payment: SwishPaymentInput

    public init(payment: SwishPaymentInput) {
      self.payment = payment
    }

    public var __variables: Variables? { ["payment": payment] }

    public struct Data: KronorApi.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { KronorApi.Objects.Mutation_root }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("newSwishPayment", NewSwishPayment.self, arguments: ["pay": .variable("payment")]),
      ] }

      /// Create a new payment request to receive money via swish
      public var newSwishPayment: NewSwishPayment { __data["newSwishPayment"] }

      /// NewSwishPayment
      ///
      /// Parent Type: `SwishPaymentResult`
      public struct NewSwishPayment: KronorApi.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { KronorApi.Objects.SwishPaymentResult }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("waitToken", String.self),
        ] }

        /// Once a payment is initialized, we will start the swish payment
        /// workflow. You can use this token to query the current status
        /// of the payment.
        public var waitToken: String { __data["waitToken"] }
      }
    }
  }

}