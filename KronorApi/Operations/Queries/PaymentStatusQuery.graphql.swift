// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension KronorApi {
  nonisolated struct PaymentStatusQuery: GraphQLQuery {
    public static let operationName: String = "PaymentStatusQuery"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query PaymentStatusQuery { paymentRequests(orderBy: { createdAt: ASC }) { __typename waitToken amount status { __typename status } createdAt resultingPaymentId transactionSwishDetails { __typename errorCode returnUrl qrCode } transactionCreditCardDetails { __typename sessionId sessionUrl } transactionMobilePayDetails { __typename sessionId sessionUrl } transactionVippsDetails { __typename sessionId sessionUrl } transactionBankTransferDetails { __typename payUrl } } }"#
      ))

    public init() {}

    nonisolated public struct Data: KronorApi.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.Query_root }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("paymentRequests", [PaymentRequest].self, arguments: ["orderBy": ["createdAt": "ASC"]]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        PaymentStatusQuery.Data.self
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
          .field("waitToken", KronorApi.Uuid.self),
          .field("amount", KronorApi.Bigint.self),
          .field("status", [Status]?.self),
          .field("createdAt", KronorApi.Timestamptz.self),
          .field("resultingPaymentId", KronorApi.Bigint?.self),
          .field("transactionSwishDetails", [TransactionSwishDetail]?.self),
          .field("transactionCreditCardDetails", [TransactionCreditCardDetail]?.self),
          .field("transactionMobilePayDetails", [TransactionMobilePayDetail]?.self),
          .field("transactionVippsDetails", [TransactionVippsDetail]?.self),
          .field("transactionBankTransferDetails", [TransactionBankTransferDetail]?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          PaymentStatusQuery.Data.PaymentRequest.self
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

        /// PaymentRequest.Status
        ///
        /// Parent Type: `CurrentPaymentStatus`
        nonisolated public struct Status: KronorApi.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.CurrentPaymentStatus }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("status", GraphQLEnum<KronorApi.PaymentStatusEnum>.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            PaymentStatusQuery.Data.PaymentRequest.Status.self
          ] }

          public var status: GraphQLEnum<KronorApi.PaymentStatusEnum> { __data["status"] }
        }

        /// PaymentRequest.TransactionSwishDetail
        ///
        /// Parent Type: `SwishDetails`
        nonisolated public struct TransactionSwishDetail: KronorApi.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.SwishDetails }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("errorCode", String?.self),
            .field("returnUrl", String?.self),
            .field("qrCode", String?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            PaymentStatusQuery.Data.PaymentRequest.TransactionSwishDetail.self
          ] }

          /// Error code from swish
          public var errorCode: String? { __data["errorCode"] }
          public var returnUrl: String? { __data["returnUrl"] }
          public var qrCode: String? { __data["qrCode"] }
        }

        /// PaymentRequest.TransactionCreditCardDetail
        ///
        /// Parent Type: `CreditCardDetails`
        nonisolated public struct TransactionCreditCardDetail: KronorApi.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.CreditCardDetails }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("sessionId", String?.self),
            .field("sessionUrl", String?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            PaymentStatusQuery.Data.PaymentRequest.TransactionCreditCardDetail.self
          ] }

          /// Session id
          public var sessionId: String? { __data["sessionId"] }
          /// Session url
          public var sessionUrl: String? { __data["sessionUrl"] }
        }

        /// PaymentRequest.TransactionMobilePayDetail
        ///
        /// Parent Type: `MobilePayDetails`
        nonisolated public struct TransactionMobilePayDetail: KronorApi.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.MobilePayDetails }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("sessionId", String?.self),
            .field("sessionUrl", String?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            PaymentStatusQuery.Data.PaymentRequest.TransactionMobilePayDetail.self
          ] }

          /// Session id
          public var sessionId: String? { __data["sessionId"] }
          /// Session url
          public var sessionUrl: String? { __data["sessionUrl"] }
        }

        /// PaymentRequest.TransactionVippsDetail
        ///
        /// Parent Type: `VippsDetails`
        nonisolated public struct TransactionVippsDetail: KronorApi.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.VippsDetails }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("sessionId", String?.self),
            .field("sessionUrl", String?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            PaymentStatusQuery.Data.PaymentRequest.TransactionVippsDetail.self
          ] }

          /// Session id
          public var sessionId: String? { __data["sessionId"] }
          /// Session url
          public var sessionUrl: String? { __data["sessionUrl"] }
        }

        /// PaymentRequest.TransactionBankTransferDetail
        ///
        /// Parent Type: `BankTransferDetails`
        nonisolated public struct TransactionBankTransferDetail: KronorApi.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.BankTransferDetails }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("payUrl", String?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            PaymentStatusQuery.Data.PaymentRequest.TransactionBankTransferDetail.self
          ] }

          public var payUrl: String? { __data["payUrl"] }
        }
      }
    }
  }

}