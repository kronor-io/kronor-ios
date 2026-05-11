// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension KronorApi {
  nonisolated struct PaymentStatusSubscription: GraphQLSubscription {
    public static let operationName: String = "PaymentStatus"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"subscription PaymentStatus { paymentRequests(orderBy: { createdAt: ASC }) { __typename ...PaymentRequestFields } }"#,
        fragments: [PaymentRequestFields.self]
      ))

    public init() {}

    nonisolated public struct Data: KronorApi.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.Subscription_root }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("paymentRequests", [PaymentRequest].self, arguments: ["orderBy": ["createdAt": "ASC"]]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        PaymentStatusSubscription.Data.self
      ] }

      /// Get the list of payment requests
      public var paymentRequests: [PaymentRequest] { __data["paymentRequests"] }

      /// PaymentRequest
      ///
      /// Parent Type: `PaymentRequest`
      nonisolated public struct PaymentRequest: KronorApi.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.PaymentRequest }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(PaymentRequestFields.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          PaymentStatusSubscription.Data.PaymentRequest.self,
          PaymentRequestFields.self
        ] }

        public var waitToken: KronorApi.Uuid { __data["waitToken"] }
        public var amount: KronorApi.Bigint { __data["amount"] }
        /// List of statuses the payment is currently on
        public var status: [Status]? { __data["status"] }
        public var createdAt: KronorApi.Timestamptz { __data["createdAt"] }
        /// Id of the generated gateway payment (stand alone payments only).
        public var resultingPaymentId: KronorApi.Bigint? { __data["resultingPaymentId"] }
        /// A computed field, executes function "runtime.get_transaction_swish_details"
        public var transactionSwishDetails: [TransactionSwishDetail]? { __data["transactionSwishDetails"] }
        /// A computed field, executes function "runtime.get_transaction_credit_card_details"
        public var transactionCreditCardDetails: [TransactionCreditCardDetail]? { __data["transactionCreditCardDetails"] }
        /// A computed field, executes function "runtime.get_transaction_mobilepay_details"
        public var transactionMobilePayDetails: [TransactionMobilePayDetail]? { __data["transactionMobilePayDetails"] }
        /// A computed field, executes function "runtime.get_transaction_vipps_details"
        public var transactionVippsDetails: [TransactionVippsDetail]? { __data["transactionVippsDetails"] }
        /// A computed field, executes function "runtime.get_transaction_bank_transfer_details"
        public var transactionBankTransferDetails: [TransactionBankTransferDetail]? { __data["transactionBankTransferDetails"] }

        public struct Fragments: FragmentContainer {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public var paymentRequestFields: PaymentRequestFields { _toFragment() }
        }

        public typealias Status = PaymentRequestFields.Status

        public typealias TransactionSwishDetail = PaymentRequestFields.TransactionSwishDetail

        public typealias TransactionCreditCardDetail = PaymentRequestFields.TransactionCreditCardDetail

        public typealias TransactionMobilePayDetail = PaymentRequestFields.TransactionMobilePayDetail

        public typealias TransactionVippsDetail = PaymentRequestFields.TransactionVippsDetail

        public typealias TransactionBankTransferDetail = PaymentRequestFields.TransactionBankTransferDetail
      }
    }
  }

}