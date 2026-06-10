// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension KronorApi {
  nonisolated struct CancelSessionPaymentsMutation: GraphQLMutation {
    public static let operationName: String = "CancelSessionPayments"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CancelSessionPayments($idempotencyKey: String!) { cancelPayment(cancel: { idempotencyKey: $idempotencyKey }) { __typename waitToken } }"#
      ))

    public var idempotencyKey: String

    public init(idempotencyKey: String) {
      self.idempotencyKey = idempotencyKey
    }

    @_spi(Unsafe) public var __variables: Variables? { ["idempotencyKey": idempotencyKey] }

    nonisolated public struct Data: KronorApi.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.Mutation_root }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("cancelPayment", CancelPayment.self, arguments: ["cancel": ["idempotencyKey": .variable("idempotencyKey")]]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        CancelSessionPaymentsMutation.Data.self
      ] }

      /// Cancel payment request.
      public var cancelPayment: CancelPayment { __data["cancelPayment"] }

      /// CancelPayment
      ///
      /// Parent Type: `PaymentCancelResult`
      nonisolated public struct CancelPayment: KronorApi.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.PaymentCancelResult }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("waitToken", String?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          CancelSessionPaymentsMutation.Data.CancelPayment.self
        ] }

        /// The returned token can be used to query whether the payment has
        /// been cancelled or not.
        public var waitToken: String? { __data["waitToken"] }
      }
    }
  }

}