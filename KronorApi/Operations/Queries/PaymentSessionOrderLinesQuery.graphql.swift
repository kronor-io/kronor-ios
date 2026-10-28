// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension KronorApi {
  nonisolated struct PaymentSessionOrderLinesQuery: GraphQLQuery {
    public static let operationName: String = "PaymentSessionOrderLinesQuery"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query PaymentSessionOrderLinesQuery { paymentSessions(limit: 1) { __typename orderLines { __typename name totalAmount } } }"#
      ))

    public init() {}

    nonisolated public struct Data: KronorApi.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.Query_root }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("paymentSessions", [PaymentSession].self, arguments: ["limit": 1]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        PaymentSessionOrderLinesQuery.Data.self
      ] }

      /// Get the list of payment requests
      public var paymentSessions: [PaymentSession] { __data["paymentSessions"] }

      /// PaymentSession
      ///
      /// Parent Type: `PaymentSession`
      nonisolated public struct PaymentSession: KronorApi.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.PaymentSession }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("orderLines", [OrderLine]?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          PaymentSessionOrderLinesQuery.Data.PaymentSession.self
        ] }

        /// Purchase items supplied by the merchant for this payment session.
        public var orderLines: [OrderLine]? { __data["orderLines"] }

        /// PaymentSession.OrderLine
        ///
        /// Parent Type: `PaymentSessionOrderLine`
        nonisolated public struct OrderLine: KronorApi.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.PaymentSessionOrderLine }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", String?.self),
            .field("totalAmount", KronorApi.Bigint?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            PaymentSessionOrderLinesQuery.Data.PaymentSession.OrderLine.self
          ] }

          public var name: String? { __data["name"] }
          public var totalAmount: KronorApi.Bigint? { __data["totalAmount"] }
        }
      }
    }
  }

}