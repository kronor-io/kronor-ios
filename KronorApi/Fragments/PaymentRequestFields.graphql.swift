// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension KronorApi {
  nonisolated struct PaymentRequestFields: KronorApi.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment PaymentRequestFields on PaymentRequest { __typename waitToken amount currency status { __typename status } createdAt resultingPaymentId transactionSwishDetails { __typename errorCode returnUrl qrCode } transactionCreditCardDetails { __typename sessionId sessionUrl } transactionMobilePayDetails { __typename sessionId sessionUrl } transactionVippsDetails { __typename sessionId sessionUrl } transactionBankTransferDetails { __typename payUrl } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.PaymentRequest }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("waitToken", KronorApi.Uuid.self),
      .field("amount", KronorApi.Bigint.self),
      .field("currency", GraphQLEnum<KronorApi.SupportedCurrencyEnum>.self),
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
      PaymentRequestFields.self
    ] }

    public var waitToken: KronorApi.Uuid { __data["waitToken"] }
    public var amount: KronorApi.Bigint { __data["amount"] }
    public var currency: GraphQLEnum<KronorApi.SupportedCurrencyEnum> { __data["currency"] }
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

    /// Status
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
        PaymentRequestFields.Status.self
      ] }

      public var status: GraphQLEnum<KronorApi.PaymentStatusEnum> { __data["status"] }
    }

    /// TransactionSwishDetail
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
        PaymentRequestFields.TransactionSwishDetail.self
      ] }

      /// Error code from swish
      public var errorCode: String? { __data["errorCode"] }
      public var returnUrl: String? { __data["returnUrl"] }
      public var qrCode: String? { __data["qrCode"] }
    }

    /// TransactionCreditCardDetail
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
        PaymentRequestFields.TransactionCreditCardDetail.self
      ] }

      /// Session id
      public var sessionId: String? { __data["sessionId"] }
      /// Session url
      public var sessionUrl: String? { __data["sessionUrl"] }
    }

    /// TransactionMobilePayDetail
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
        PaymentRequestFields.TransactionMobilePayDetail.self
      ] }

      /// Session id
      public var sessionId: String? { __data["sessionId"] }
      /// Session url
      public var sessionUrl: String? { __data["sessionUrl"] }
    }

    /// TransactionVippsDetail
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
        PaymentRequestFields.TransactionVippsDetail.self
      ] }

      /// Session id
      public var sessionId: String? { __data["sessionId"] }
      /// Session url
      public var sessionUrl: String? { __data["sessionUrl"] }
    }

    /// TransactionBankTransferDetail
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
        PaymentRequestFields.TransactionBankTransferDetail.self
      ] }

      public var payUrl: String? { __data["payUrl"] }
    }
  }

}