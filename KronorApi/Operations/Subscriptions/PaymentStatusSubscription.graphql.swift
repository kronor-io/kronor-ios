// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension KronorApi {
  class PaymentStatusSubscription: GraphQLSubscription {
    public static let operationName: String = "PaymentStatus"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"subscription PaymentStatus { paymentRequests(orderBy: { createdAt: ASC }) { __typename waitToken amount status { __typename status } createdAt resultingPaymentId transactionSwishDetails { __typename errorCode returnUrl qrCode } transactionCreditCardDetails { __typename sessionId sessionUrl } transactionMobilePayDetails { __typename sessionId sessionUrl } transactionVippsDetails { __typename sessionId sessionUrl } } }"#
      ))

    public init() {}

    public struct Data: KronorApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.Subscription_root }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("paymentRequests", [PaymentRequest].self, arguments: ["orderBy": ["createdAt": "ASC"]]),
      ] }

      /// Get the list of payment requests
      public var paymentRequests: [PaymentRequest] { __data["paymentRequests"] }

      /// PaymentRequest
      ///
      /// Parent Type: `PaymentRequest`
      public struct PaymentRequest: KronorApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.PaymentRequest }
        public static var __selections: [ApolloAPI.Selection] { [
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

        /// PaymentRequest.Status
        ///
        /// Parent Type: `CurrentPaymentStatus`
        public struct Status: KronorApi.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.CurrentPaymentStatus }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("status", GraphQLEnum<KronorApi.PaymentStatusEnum>.self),
          ] }

          public var status: GraphQLEnum<KronorApi.PaymentStatusEnum> { __data["status"] }
        }

        /// PaymentRequest.TransactionSwishDetail
        ///
        /// Parent Type: `SwishDetails`
        public struct TransactionSwishDetail: KronorApi.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.SwishDetails }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("errorCode", String?.self),
            .field("returnUrl", String?.self),
            .field("qrCode", String?.self),
          ] }

          /// Error code from swish
          public var errorCode: String? { __data["errorCode"] }
          public var returnUrl: String? { __data["returnUrl"] }
          public var qrCode: String? { __data["qrCode"] }
        }

        /// PaymentRequest.TransactionCreditCardDetail
        ///
        /// Parent Type: `CreditCardDetails`
        public struct TransactionCreditCardDetail: KronorApi.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.CreditCardDetails }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("sessionId", String?.self),
            .field("sessionUrl", String?.self),
          ] }

          /// Session id
          public var sessionId: String? { __data["sessionId"] }
          /// Session url
          public var sessionUrl: String? { __data["sessionUrl"] }
        }

        /// PaymentRequest.TransactionMobilePayDetail
        ///
        /// Parent Type: `MobilePayDetails`
        public struct TransactionMobilePayDetail: KronorApi.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.MobilePayDetails }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("sessionId", String?.self),
            .field("sessionUrl", String?.self),
          ] }

          /// Session id
          public var sessionId: String? { __data["sessionId"] }
          /// Session url
          public var sessionUrl: String? { __data["sessionUrl"] }
        }

        /// PaymentRequest.TransactionVippsDetail
        ///
        /// Parent Type: `VippsDetails`
        public struct TransactionVippsDetail: KronorApi.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.VippsDetails }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("sessionId", String?.self),
            .field("sessionUrl", String?.self),
          ] }

          /// Session id
          public var sessionId: String? { __data["sessionId"] }
          /// Session url
          public var sessionUrl: String? { __data["sessionUrl"] }
        }
      }
    }
  }

}