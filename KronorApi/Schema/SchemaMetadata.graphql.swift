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
  typealias ID = String

  typealias SelectionSet = KronorApi_SelectionSet

  typealias InlineFragment = KronorApi_InlineFragment

  typealias MutableSelectionSet = KronorApi_MutableSelectionSet

  typealias MutableInlineFragment = KronorApi_MutableInlineFragment

  enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    public static func objectType(forTypename typename: String) -> Object? {
      switch typename {
      case "mutation_root": return KronorApi.Objects.Mutation_root
      case "VippsPaymentResult": return KronorApi.Objects.VippsPaymentResult
      case "AddSessionDeviceInformationResult": return KronorApi.Objects.AddSessionDeviceInformationResult
      case "MobilePayPaymentResult": return KronorApi.Objects.MobilePayPaymentResult
      case "SwishPaymentResult": return KronorApi.Objects.SwishPaymentResult
      case "CreditCardPaymentResult": return KronorApi.Objects.CreditCardPaymentResult
      case "PaymentSessionResult": return KronorApi.Objects.PaymentSessionResult
      case "subscription_root": return KronorApi.Objects.Subscription_root
      case "PaymentRequest": return KronorApi.Objects.PaymentRequest
      case "CurrentPaymentStatus": return KronorApi.Objects.CurrentPaymentStatus
      case "SwishDetails": return KronorApi.Objects.SwishDetails
      case "CreditCardDetails": return KronorApi.Objects.CreditCardDetails
      case "MobilePayDetails": return KronorApi.Objects.MobilePayDetails
      case "VippsDetails": return KronorApi.Objects.VippsDetails
      case "PaymentCancelResult": return KronorApi.Objects.PaymentCancelResult
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}