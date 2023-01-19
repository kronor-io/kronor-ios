// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension KronorApi {
  class MobilePayPaymentMutation: GraphQLMutation {
    public static let operationName: String = "MobilePayPayment"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation MobilePayPayment($payment: MobilePayPaymentInput!, $deviceInfo: AddSessionDeviceInformationInput!) {
          newMobilePayPayment(pay: $payment) {
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

    public var payment: MobilePayPaymentInput
    public var deviceInfo: AddSessionDeviceInformationInput

    public init(
      payment: MobilePayPaymentInput,
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
        .field("newMobilePayPayment", NewMobilePayPayment.self, arguments: ["pay": .variable("payment")]),
        .field("addSessionDeviceInformation", AddSessionDeviceInformation.self, arguments: ["info": .variable("deviceInfo")]),
      ] }

      /// Create a new payment request to receive money via MobilePay, available only in Denmark and Finland.
      public var newMobilePayPayment: NewMobilePayPayment { __data["newMobilePayPayment"] }
      /// Set customer device information for a given payment session.
      public var addSessionDeviceInformation: AddSessionDeviceInformation { __data["addSessionDeviceInformation"] }

      /// NewMobilePayPayment
      ///
      /// Parent Type: `MobilePayPaymentResult`
      public struct NewMobilePayPayment: KronorApi.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { KronorApi.Objects.MobilePayPaymentResult }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("waitToken", String.self),
        ] }

        /// Once a payment is initialized, we will start the MobilePay payment
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