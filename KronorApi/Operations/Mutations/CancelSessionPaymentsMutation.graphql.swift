// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension KronorApi {
  class CancelSessionPaymentsMutation: GraphQLMutation {
    public static let operationName: String = "CancelSessionPayments"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CancelSessionPayments($idempotencyKey: String!) { cancelPayment(cancel: { idempotencyKey: $idempotencyKey }) { __typename waitToken } }"#
      ))

    public var idempotencyKey: String

    public init(idempotencyKey: String) {
      self.idempotencyKey = idempotencyKey
    }

    public var __variables: Variables? { ["idempotencyKey": idempotencyKey] }

    public struct Data: KronorApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.Mutation_root }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("cancelPayment", CancelPayment.self, arguments: ["cancel": ["idempotencyKey": .variable("idempotencyKey")]]),
      ] }

      /// Cancel payment request.
      public var cancelPayment: CancelPayment { __data["cancelPayment"] }

      /// CancelPayment
      ///
      /// Parent Type: `PaymentCancelResult`
      public struct CancelPayment: KronorApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.PaymentCancelResult }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("waitToken", String?.self),
        ] }

        /// The returned token can be used to query whether the payment has
        /// been cancelled or not.
        public var waitToken: String? { __data["waitToken"] }
      }
    }
  }

}