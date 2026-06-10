// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension KronorApi {
  nonisolated struct BankTransferPaymentMutation: GraphQLMutation {
    public static let operationName: String = "BankTransferPayment"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation BankTransferPayment($payment: BankTransferPaymentInput!, $deviceInfo: AddSessionDeviceInformationInput!) { newBankTransferPayment(pay: $payment) { __typename paymentRequestId paymentId gateway } addSessionDeviceInformation(info: $deviceInfo) { __typename result } }"#
      ))

    public var payment: BankTransferPaymentInput
    public var deviceInfo: AddSessionDeviceInformationInput

    public init(
      payment: BankTransferPaymentInput,
      deviceInfo: AddSessionDeviceInformationInput
    ) {
      self.payment = payment
      self.deviceInfo = deviceInfo
    }

    @_spi(Unsafe) public var __variables: Variables? { [
      "payment": payment,
      "deviceInfo": deviceInfo
    ] }

    nonisolated public struct Data: KronorApi.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.Mutation_root }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("newBankTransferPayment", NewBankTransferPayment.self, arguments: ["pay": .variable("payment")]),
        .field("addSessionDeviceInformation", AddSessionDeviceInformation.self, arguments: ["info": .variable("deviceInfo")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        BankTransferPaymentMutation.Data.self
      ] }

      /// Create a new payment request via bank transfer
      public var newBankTransferPayment: NewBankTransferPayment { __data["newBankTransferPayment"] }
      /// Set customer device information for a given payment session.
      public var addSessionDeviceInformation: AddSessionDeviceInformation { __data["addSessionDeviceInformation"] }

      /// NewBankTransferPayment
      ///
      /// Parent Type: `BankTransferPaymentResult`
      nonisolated public struct NewBankTransferPayment: KronorApi.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.BankTransferPaymentResult }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("paymentRequestId", String?.self),
          .field("paymentId", String.self),
          .field("gateway", GraphQLEnum<KronorApi.GatewayEnum>.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          BankTransferPaymentMutation.Data.NewBankTransferPayment.self
        ] }

        /// Once a payment is initialized, we will start the open banking
        /// payment workflow. You can use this token to query the current status
        /// of the payment, with paymentRequests query.
        public var paymentRequestId: String? { __data["paymentRequestId"] }
        /// Once a payment is initialized, we will start the open banking
        /// payment workflow. You can use this paymentId to query the current status
        /// of the payment, with paymentRequests query.
        public var paymentId: String { __data["paymentId"] }
        /// The gateway this bank transfer payment will use.
        public var gateway: GraphQLEnum<KronorApi.GatewayEnum> { __data["gateway"] }
      }

      /// AddSessionDeviceInformation
      ///
      /// Parent Type: `AddSessionDeviceInformationResult`
      nonisolated public struct AddSessionDeviceInformation: KronorApi.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.AddSessionDeviceInformationResult }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("result", Bool.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          BankTransferPaymentMutation.Data.AddSessionDeviceInformation.self
        ] }

        /// True when customer device data has been stored correctly.
        public var result: Bool { __data["result"] }
      }
    }
  }

}