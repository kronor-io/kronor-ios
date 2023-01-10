// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension KronorApi {
  class PaymentStatusSubscription: GraphQLSubscription {
    public static let operationName: String = "PaymentStatus"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        subscription PaymentStatus {
          paymentRequests(orderBy: {createdAt: ASC}) {
            __typename
            waitToken
            amount
            merchant {
              __typename
              currency
            }
            detail {
              __typename
              detail
            }
            status {
              __typename
              status
            }
            createdAt
            resultingPaymentId
            transactionSwishDetails {
              __typename
              errorCode
            }
            transactionCreditCardDetails {
              __typename
              sessionId
              sessionUrl
            }
            transactionMobilePayDetails {
              __typename
              sessionId
              sessionUrl
            }
            transactionVippsDetails {
              __typename
              sessionId
              sessionUrl
            }
            paymentFlow
          }
        }
        """#
      ))

    public init() {}

    public struct Data: KronorApi.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { KronorApi.Objects.Subscription_root }
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
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { KronorApi.Objects.PaymentRequest }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("waitToken", KronorApi.Uuid.self),
          .field("amount", KronorApi.Bigint.self),
          .field("merchant", Merchant.self),
          .field("detail", [Detail]?.self),
          .field("status", [Status]?.self),
          .field("createdAt", KronorApi.Timestamptz.self),
          .field("resultingPaymentId", KronorApi.Bigint?.self),
          .field("transactionSwishDetails", [TransactionSwishDetail]?.self),
          .field("transactionCreditCardDetails", [TransactionCreditCardDetail]?.self),
          .field("transactionMobilePayDetails", [TransactionMobilePayDetail]?.self),
          .field("transactionVippsDetails", [TransactionVippsDetail]?.self),
          .field("paymentFlow", String?.self),
        ] }

        public var waitToken: KronorApi.Uuid { __data["waitToken"] }
        public var amount: KronorApi.Bigint { __data["amount"] }
        /// An object relationship
        public var merchant: Merchant { __data["merchant"] }
        /// Additional information specific to the payment
        public var detail: [Detail]? { __data["detail"] }
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
        public var paymentFlow: String? { __data["paymentFlow"] }

        /// PaymentRequest.Merchant
        ///
        /// Parent Type: `Merchant`
        public struct Merchant: KronorApi.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ApolloAPI.ParentType { KronorApi.Objects.Merchant }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("currency", KronorApi.Currency.self),
          ] }

          /// Currency in which the purchase and other operations are done.
          /// Only currencies in ISO-4217 format are recognized.
          /// The currency needs to match the supported currencies for the merchant.
          /// Example: SEK, EUR.
          public var currency: KronorApi.Currency { __data["currency"] }
        }

        /// PaymentRequest.Detail
        ///
        /// Parent Type: `CurrentPaymentDetail`
        public struct Detail: KronorApi.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ApolloAPI.ParentType { KronorApi.Objects.CurrentPaymentDetail }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("detail", KronorApi.Jsonb.self),
          ] }

          public var detail: KronorApi.Jsonb { __data["detail"] }
        }

        /// PaymentRequest.Status
        ///
        /// Parent Type: `CurrentPaymentStatus`
        public struct Status: KronorApi.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ApolloAPI.ParentType { KronorApi.Objects.CurrentPaymentStatus }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("status", GraphQLEnum<KronorApi.PaymentStatusEnum>.self),
          ] }

          public var status: GraphQLEnum<KronorApi.PaymentStatusEnum> { __data["status"] }
        }

        /// PaymentRequest.TransactionSwishDetail
        ///
        /// Parent Type: `SwishDetails`
        public struct TransactionSwishDetail: KronorApi.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ApolloAPI.ParentType { KronorApi.Objects.SwishDetails }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("errorCode", String?.self),
          ] }

          /// Error code from swish
          public var errorCode: String? { __data["errorCode"] }
        }

        /// PaymentRequest.TransactionCreditCardDetail
        ///
        /// Parent Type: `CreditCardDetails`
        public struct TransactionCreditCardDetail: KronorApi.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ApolloAPI.ParentType { KronorApi.Objects.CreditCardDetails }
          public static var __selections: [ApolloAPI.Selection] { [
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
          public init(data: DataDict) { __data = data }

          public static var __parentType: ApolloAPI.ParentType { KronorApi.Objects.MobilePayDetails }
          public static var __selections: [ApolloAPI.Selection] { [
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
          public init(data: DataDict) { __data = data }

          public static var __parentType: ApolloAPI.ParentType { KronorApi.Objects.VippsDetails }
          public static var __selections: [ApolloAPI.Selection] { [
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