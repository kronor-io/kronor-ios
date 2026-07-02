// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

nonisolated public protocol KronorApi_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == KronorApi.SchemaMetadata {}

nonisolated public protocol KronorApi_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == KronorApi.SchemaMetadata {}

nonisolated public protocol KronorApi_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == KronorApi.SchemaMetadata {}

nonisolated public protocol KronorApi_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == KronorApi.SchemaMetadata {}

public extension KronorApi {
  typealias SelectionSet = KronorApi_SelectionSet

  typealias InlineFragment = KronorApi_InlineFragment

  typealias MutableSelectionSet = KronorApi_MutableSelectionSet

  typealias MutableInlineFragment = KronorApi_MutableInlineFragment

  nonisolated enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    public static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    private static let objectTypeMap: [String: ApolloAPI.Object] = [
      "AddSessionDeviceInformationResult": KronorApi.Objects.AddSessionDeviceInformationResult,
      "ApplePayPaymentResult": KronorApi.Objects.ApplePayPaymentResult,
      "BankTransferDetails": KronorApi.Objects.BankTransferDetails,
      "BankTransferPaymentResult": KronorApi.Objects.BankTransferPaymentResult,
      "CreditCardDetails": KronorApi.Objects.CreditCardDetails,
      "CreditCardPaymentResult": KronorApi.Objects.CreditCardPaymentResult,
      "CurrentPaymentStatus": KronorApi.Objects.CurrentPaymentStatus,
      "MobilePayDetails": KronorApi.Objects.MobilePayDetails,
      "MobilePayPaymentResult": KronorApi.Objects.MobilePayPaymentResult,
      "PayPalPaymentResult": KronorApi.Objects.PayPalPaymentResult,
      "PaymentCancelResult": KronorApi.Objects.PaymentCancelResult,
      "PaymentRequest": KronorApi.Objects.PaymentRequest,
      "RefreshPaymentStatusResult": KronorApi.Objects.RefreshPaymentStatusResult,
      "SwishDetails": KronorApi.Objects.SwishDetails,
      "SwishPaymentResult": KronorApi.Objects.SwishPaymentResult,
      "VippsDetails": KronorApi.Objects.VippsDetails,
      "VippsPaymentResult": KronorApi.Objects.VippsPaymentResult,
      "mutation_root": KronorApi.Objects.Mutation_root,
      "query_root": KronorApi.Objects.Query_root,
      "subscription_root": KronorApi.Objects.Subscription_root
    ]

    @_spi(Execution) public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
      objectTypeMap[typename]
    }
  }

  nonisolated enum Objects {}
  nonisolated enum Interfaces {}
  nonisolated enum Unions {}

}