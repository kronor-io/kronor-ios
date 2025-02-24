// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension KronorApi {
  class CreditCardPaymentMutation: GraphQLMutation {
    public static let operationName: String = "CreditCardPayment"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CreditCardPayment($payment: CreditCardPaymentInput!, $deviceInfo: AddSessionDeviceInformationInput!) { newCreditCardPayment(pay: $payment) { __typename waitToken } addSessionDeviceInformation(info: $deviceInfo) { __typename result } }"#
      ))

    public var payment: CreditCardPaymentInput
    public var deviceInfo: AddSessionDeviceInformationInput

    public init(
      payment: CreditCardPaymentInput,
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
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.Mutation_root }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("newCreditCardPayment", NewCreditCardPayment.self, arguments: ["pay": .variable("payment")]),
        .field("addSessionDeviceInformation", AddSessionDeviceInformation.self, arguments: ["info": .variable("deviceInfo")]),
      ] }

      /// Create a new payment request to receive money via credit card
      public var newCreditCardPayment: NewCreditCardPayment { __data["newCreditCardPayment"] }
      /// Set customer device information for a given payment session.
      public var addSessionDeviceInformation: AddSessionDeviceInformation { __data["addSessionDeviceInformation"] }

      /// NewCreditCardPayment
      ///
      /// Parent Type: `CreditCardPaymentResult`
      public struct NewCreditCardPayment: KronorApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.CreditCardPaymentResult }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("waitToken", String.self),
        ] }

        /// Once a payment is initialized, we will start the credit card payment
        /// workflow. You can use this token to query the current status
        /// of the payment, with paymentRequests query.
        public var waitToken: String { __data["waitToken"] }
      }

      /// AddSessionDeviceInformation
      ///
      /// Parent Type: `AddSessionDeviceInformationResult`
      public struct AddSessionDeviceInformation: KronorApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { KronorApi.Objects.AddSessionDeviceInformationResult }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("result", Bool.self),
        ] }

        /// True when customer device data has been stored correctly.
        public var result: Bool { __data["result"] }
      }
    }
  }

}