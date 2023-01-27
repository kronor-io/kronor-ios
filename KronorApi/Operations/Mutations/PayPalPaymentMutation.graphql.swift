// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension KronorApi {
  class PayPalPaymentMutation: GraphQLMutation {
    public static let operationName: String = "PayPalPayment"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation PayPalPayment($payment: PayPalPaymentInput!, $deviceInfo: AddSessionDeviceInformationInput!) {
          newPayPalPayment(pay: $payment) {
            __typename
            paymentId
            amount
            currency
          }
          addSessionDeviceInformation(info: $deviceInfo) {
            __typename
            result
          }
        }
        """#
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

    public var __variables: Variables? { [
      "payment": payment,
      "deviceInfo": deviceInfo
    ] }

    public struct Data: KronorApi.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { KronorApi.Objects.Mutation_root }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("newPayPalPayment", NewPayPalPayment.self, arguments: ["pay": .variable("payment")]),
        .field("addSessionDeviceInformation", AddSessionDeviceInformation.self, arguments: ["info": .variable("deviceInfo")]),
      ] }

      /// Create a new payment request to receive money via PayPal
      public var newPayPalPayment: NewPayPalPayment { __data["newPayPalPayment"] }
      /// Set customer device information for a given payment session.
      public var addSessionDeviceInformation: AddSessionDeviceInformation { __data["addSessionDeviceInformation"] }

      /// NewPayPalPayment
      ///
      /// Parent Type: `PayPalPaymentResult`
      public struct NewPayPalPayment: KronorApi.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { KronorApi.Objects.PayPalPaymentResult }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("paymentId", String.self),
          .field("amount", String.self),
          .field("currency", String.self),
        ] }

        /// Once a payment is initialized, we will start the PayPal payment
        /// workflow. You can use this id to query the current status of the
        /// payment.
        public var paymentId: String { __data["paymentId"] }
        /// The amount the customer pays in minor units.
        /// So 100,56 kr would be 10056
        public var amount: String { __data["amount"] }
        /// The currency of the payment
        public var currency: String { __data["currency"] }
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