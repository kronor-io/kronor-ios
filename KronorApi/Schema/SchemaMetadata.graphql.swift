// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public protocol KronorApi_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == KronorApi.SchemaMetadata {}

public protocol KronorApi_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == KronorApi.SchemaMetadata {}

public protocol KronorApi_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == KronorApi.SchemaMetadata {}

public protocol KronorApi_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == KronorApi.SchemaMetadata {}

public extension KronorApi {
  typealias SelectionSet = KronorApi_SelectionSet

  typealias InlineFragment = KronorApi_InlineFragment

  typealias MutableSelectionSet = KronorApi_MutableSelectionSet

  typealias MutableInlineFragment = KronorApi_MutableInlineFragment

  enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    public static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
      switch typename {
      case "AddSessionDeviceInformationResult": return KronorApi.Objects.AddSessionDeviceInformationResult
      case "CreditCardDetails": return KronorApi.Objects.CreditCardDetails
      case "CreditCardPaymentResult": return KronorApi.Objects.CreditCardPaymentResult
      case "CurrentPaymentStatus": return KronorApi.Objects.CurrentPaymentStatus
      case "MobilePayDetails": return KronorApi.Objects.MobilePayDetails
      case "MobilePayPaymentResult": return KronorApi.Objects.MobilePayPaymentResult
      case "PayPalPaymentResult": return KronorApi.Objects.PayPalPaymentResult
      case "PaymentCancelResult": return KronorApi.Objects.PaymentCancelResult
      case "PaymentRequest": return KronorApi.Objects.PaymentRequest
      case "SwishDetails": return KronorApi.Objects.SwishDetails
      case "SwishPaymentResult": return KronorApi.Objects.SwishPaymentResult
      case "VippsDetails": return KronorApi.Objects.VippsDetails
      case "VippsPaymentResult": return KronorApi.Objects.VippsPaymentResult
      case "mutation_root": return KronorApi.Objects.Mutation_root
      case "query_root": return KronorApi.Objects.Query_root
      case "subscription_root": return KronorApi.Objects.Subscription_root
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}