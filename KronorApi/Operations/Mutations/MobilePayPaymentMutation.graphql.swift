// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension KronorApi {
  nonisolated struct MobilePayPaymentMutation: GraphQLMutation {
    public static let operationName: String = "MobilePayPayment"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation MobilePayPayment($payment: MobilePayPaymentInput!, $deviceInfo: AddSessionDeviceInformationInput!) { newMobilePayPayment(pay: $payment) { __typename waitToken } addSessionDeviceInformation(info: $deviceInfo) { __typename result } }"#
      ))

    public var payment: MobilePayPaymentInput
    public var deviceInfo: AddSessionDeviceInformationInput

    public init(
      payment: MobilePayPaymentInput,
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
        .field("newMobilePayPayment", NewMobilePayPayment.self, arguments: ["pay": .variable("payment")]),
        .field("addSessionDeviceInformation", AddSessionDeviceInformation.self, arguments: ["info": .variable("deviceInfo")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MobilePayPaymentMutation.Data.self
      ] }

      /// Create a new payment request to receive money via MobilePay, available only in Denmark and Finland.
      public var newMobilePayPayment: NewMobilePayPayment { __data["newMobilePayPayment"] }
      /// Set customer device information for a given payment session.
      public var addSessionDeviceInformation: AddSessionDeviceInformation { __data["addSessionDeviceInformation"] }

      /// NewMobilePayPayment
      ///
      /// Parent Type: `MobilePayPaymentResult`
      nonisolated public struct NewMobilePayPayment: KronorApi.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.MobilePayPaymentResult }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("waitToken", String.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MobilePayPaymentMutation.Data.NewMobilePayPayment.self
        ] }

        /// Once a payment is initialized, we will start the MobilePay payment
        /// workflow. You can use this token to query the current status
        /// of the payment, with paymentRequests query.
        public var waitToken: String { __data["waitToken"] }
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
          MobilePayPaymentMutation.Data.AddSessionDeviceInformation.self
        ] }

        /// True when customer device data has been stored correctly.
        public var result: Bool { __data["result"] }
      }
    }
  }

}