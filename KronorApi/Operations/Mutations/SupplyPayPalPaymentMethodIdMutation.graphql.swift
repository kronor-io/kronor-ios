// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension KronorApi {
  class SupplyPayPalPaymentMethodIdMutation: GraphQLMutation {
    public static let operationName: String = "SupplyPayPalPaymentMethodId"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation SupplyPayPalPaymentMethodId($payment: SupplyPayPalPaymentMethodIdInput!) {
          supplyPayPalPaymentMethodId(pay: $payment) {
            __typename
            paymentId
          }
        }
        """#
      ))

    public var payment: SupplyPayPalPaymentMethodIdInput

    public init(payment: SupplyPayPalPaymentMethodIdInput) {
      self.payment = payment
    }

    public var __variables: Variables? { ["payment": payment] }

    public struct Data: KronorApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KronorApi.Objects.Mutation_root }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("supplyPayPalPaymentMethodId", SupplyPayPalPaymentMethodId.self, arguments: ["pay": .variable("payment")]),
      ] }

      /// Supply PaymentMethodId (nonce) to progress PayPal paymeent
      public var supplyPayPalPaymentMethodId: SupplyPayPalPaymentMethodId { __data["supplyPayPalPaymentMethodId"] }

      /// SupplyPayPalPaymentMethodId
      ///
      /// Parent Type: `SupplyPayPalPaymentMethodIdResult`
      public struct SupplyPayPalPaymentMethodId: KronorApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KronorApi.Objects.SupplyPayPalPaymentMethodIdResult }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("paymentId", String.self),
        ] }

        /// Once a payment is initialized, we will start the PayPal payment
        /// workflow. You can use this id to query the current status of the
        /// payment.
        public var paymentId: String { __data["paymentId"] }
      }
    }
  }

}