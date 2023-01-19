// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension KronorApi {
  class VippsPaymentMutation: GraphQLMutation {
    public static let operationName: String = "VippsPayment"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation VippsPayment($payment: VippsPaymentInput!, $deviceInfo: AddSessionDeviceInformationInput!) {
          newVippsPayment(pay: $payment) {
            __typename
            waitToken
          }
          addSessionDeviceInformation(info: $deviceInfo) {
            __typename
            result
          }
        }
        """#
      ))

    public var payment: VippsPaymentInput
    public var deviceInfo: AddSessionDeviceInformationInput

    public init(
      payment: VippsPaymentInput,
      deviceInfo: AddSessionDeviceInformationInput
    ) {
      self.payment = payment
      self.deviceInfo = deviceInfo
    }

    public var __variables: Variables? { [
      "payment": payment,
      "deviceInfo": deviceInfo
    ] }

    public struct Data: KronorApi.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { KronorApi.Objects.Mutation_root }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("newVippsPayment", NewVippsPayment.self, arguments: ["pay": .variable("payment")]),
        .field("addSessionDeviceInformation", AddSessionDeviceInformation.self, arguments: ["info": .variable("deviceInfo")]),
      ] }

      /// Create a new payment request to receive money via Vipps, available only in Norway.
      public var newVippsPayment: NewVippsPayment { __data["newVippsPayment"] }
      /// Set customer device information for a given payment session.
      public var addSessionDeviceInformation: AddSessionDeviceInformation { __data["addSessionDeviceInformation"] }

      /// NewVippsPayment
      ///
      /// Parent Type: `VippsPaymentResult`
      public struct NewVippsPayment: KronorApi.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { KronorApi.Objects.VippsPaymentResult }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("waitToken", String.self),
        ] }

        /// Once a payment is initialized, we will start the Vipps payment
        /// workflow. You can use this token to query the current status
        /// of the payment, with paymentRequests query.
        public var waitToken: String { __data["waitToken"] }
      }

      /// AddSessionDeviceInformation
      ///
      /// Parent Type: `AddSessionDeviceInformationResult`
      public struct AddSessionDeviceInformation: KronorApi.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { KronorApi.Objects.AddSessionDeviceInformationResult }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("result", Bool.self),
        ] }

        /// True when customer device data has been stored correctly.
        public var result: Bool { __data["result"] }
      }
    }
  }

}