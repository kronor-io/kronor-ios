// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension KronorApi {
  nonisolated struct SwishPaymentMutation: GraphQLMutation {
    public static let operationName: String = "SwishPayment"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation SwishPayment($payment: SwishPaymentInput!, $deviceInfo: AddSessionDeviceInformationInput!) { newSwishPayment(pay: $payment) { __typename waitToken } addSessionDeviceInformation(info: $deviceInfo) { __typename result } }"#
      ))

    public var payment: SwishPaymentInput
    public var deviceInfo: AddSessionDeviceInformationInput

    public init(
      payment: SwishPaymentInput,
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
        .field("newSwishPayment", NewSwishPayment.self, arguments: ["pay": .variable("payment")]),
        .field("addSessionDeviceInformation", AddSessionDeviceInformation.self, arguments: ["info": .variable("deviceInfo")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        SwishPaymentMutation.Data.self
      ] }

      /// Create a new payment request to receive money via swish
      public var newSwishPayment: NewSwishPayment { __data["newSwishPayment"] }
      /// Set customer device information for a given payment session.
      public var addSessionDeviceInformation: AddSessionDeviceInformation { __data["addSessionDeviceInformation"] }

      /// NewSwishPayment
      ///
      /// Parent Type: `SwishPaymentResult`
      nonisolated public struct NewSwishPayment: KronorApi.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.SwishPaymentResult }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("waitToken", String.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          SwishPaymentMutation.Data.NewSwishPayment.self
        ] }

        /// Once a payment is initialized, we will start the swish payment
        /// workflow. You can use this token to query the current status
        /// of the payment.
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
          SwishPaymentMutation.Data.AddSessionDeviceInformation.self
        ] }

        /// True when customer device data has been stored correctly.
        public var result: Bool { __data["result"] }
      }
    }
  }

}