// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension KronorApi {
  nonisolated struct ApplePayPaymentMutation: GraphQLMutation {
    public static let operationName: String = "ApplePayPayment"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation ApplePayPayment($payment: ApplePayPaymentInput!, $deviceInfo: AddSessionDeviceInformationInput!) { newApplePayPayment(pay: $payment) { __typename waitToken gateway authToken } addSessionDeviceInformation(info: $deviceInfo) { __typename result } }"#
      ))

    public var payment: ApplePayPaymentInput
    public var deviceInfo: AddSessionDeviceInformationInput

    public init(
      payment: ApplePayPaymentInput,
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
        .field("newApplePayPayment", NewApplePayPayment.self, arguments: ["pay": .variable("payment")]),
        .field("addSessionDeviceInformation", AddSessionDeviceInformation.self, arguments: ["info": .variable("deviceInfo")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ApplePayPaymentMutation.Data.self
      ] }

      /// Create a new payment request to accept a payment from Apple Pay
      public var newApplePayPayment: NewApplePayPayment { __data["newApplePayPayment"] }
      /// Set customer device information for a given payment session.
      public var addSessionDeviceInformation: AddSessionDeviceInformation { __data["addSessionDeviceInformation"] }

      /// NewApplePayPayment
      ///
      /// Parent Type: `ApplePayPaymentResult`
      nonisolated public struct NewApplePayPayment: KronorApi.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.ApplePayPaymentResult }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("waitToken", String.self),
          .field("gateway", GraphQLEnum<KronorApi.GatewayEnum>.self),
          .field("authToken", String?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ApplePayPaymentMutation.Data.NewApplePayPayment.self
        ] }

        /// Once a payment is initialized, we will start the apple pay payment
        /// workflow. You can use this token to query the current status
        /// of the payment, with paymentRequests query.
        public var waitToken: String { __data["waitToken"] }
        /// The gateway that will process the card.
        public var gateway: GraphQLEnum<KronorApi.GatewayEnum> { __data["gateway"] }
        /// Token used to authorize the payment against the card data environment
        /// (CDE) API. Only present when the payment is processed by the KRONOR
        /// gateway.
        public var authToken: String? { __data["authToken"] }
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
          ApplePayPaymentMutation.Data.AddSessionDeviceInformation.self
        ] }

        /// True when customer device data has been stored correctly.
        public var result: Bool { __data["result"] }
      }
    }
  }

}