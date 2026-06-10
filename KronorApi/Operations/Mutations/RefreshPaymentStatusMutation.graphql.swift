// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension KronorApi {
  nonisolated struct RefreshPaymentStatusMutation: GraphQLMutation {
    public static let operationName: String = "RefreshPaymentStatus"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation RefreshPaymentStatus { refreshPaymentStatus { __typename result } }"#
      ))

    public init() {}

    nonisolated public struct Data: KronorApi.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.Mutation_root }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("refreshPaymentStatus", RefreshPaymentStatus.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        RefreshPaymentStatusMutation.Data.self
      ] }

      /// Trigger an immediate poll of the payment provider's status. Fired when
      /// the customer is redirected back to Kronor from the provider's app
      /// so the backend re-checks status immediately instead of waiting on
      /// the provider's webhook (which can arrive late) or the next scheduled
      /// poll.
      public var refreshPaymentStatus: RefreshPaymentStatus { __data["refreshPaymentStatus"] }

      /// RefreshPaymentStatus
      ///
      /// Parent Type: `RefreshPaymentStatusResult`
      nonisolated public struct RefreshPaymentStatus: KronorApi.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.RefreshPaymentStatusResult }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("result", Bool.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          RefreshPaymentStatusMutation.Data.RefreshPaymentStatus.self
        ] }

        /// True when the immediate status poll was accepted. The actual status
        /// change lands asynchronously once the poll completes; the frontend
        /// continues its normal status subscription/polling.
        public var result: Bool { __data["result"] }
      }
    }
  }

}