// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension KronorApi {
  nonisolated struct PayPalPaymentMutation: GraphQLMutation {
    public static let operationName: String = "PayPalPayment"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation PayPalPayment($payment: PayPalPaymentInput!, $deviceInfo: AddSessionDeviceInformationInput!) { newPayPalPayment(pay: $payment) { __typename paymentId } addSessionDeviceInformation(info: $deviceInfo) { __typename result } }"#
      ))

    public var payment: PayPalPaymentInput
    public var deviceInfo: AddSessionDeviceInformationInput

    public init(
      payment: PayPalPaymentInput,
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
        .field("newPayPalPayment", NewPayPalPayment.self, arguments: ["pay": .variable("payment")]),
        .field("addSessionDeviceInformation", AddSessionDeviceInformation.self, arguments: ["info": .variable("deviceInfo")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        PayPalPaymentMutation.Data.self
      ] }

      /// Create a new payment request to receive money via PayPal
      public var newPayPalPayment: NewPayPalPayment { __data["newPayPalPayment"] }
      /// Set customer device information for a given payment session.
      public var addSessionDeviceInformation: AddSessionDeviceInformation { __data["addSessionDeviceInformation"] }

      /// NewPayPalPayment
      ///
      /// Parent Type: `PayPalPaymentResult`
      nonisolated public struct NewPayPalPayment: KronorApi.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.PayPalPaymentResult }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("paymentId", String.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          PayPalPaymentMutation.Data.NewPayPalPayment.self
        ] }

        /// Once a payment is initialized, we will start the PayPal payment
        /// workflow. You can use this id to query the current status of the
        /// payment.
        public var paymentId: String { __data["paymentId"] }
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
          PayPalPaymentMutation.Data.AddSessionDeviceInformation.self
        ] }

        /// True when customer device data has been stored correctly.
        public var result: Bool { __data["result"] }
      }
    }
  }

}