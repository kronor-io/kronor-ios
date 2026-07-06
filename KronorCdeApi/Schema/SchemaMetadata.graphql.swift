// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

nonisolated public protocol KronorCdeApi_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == KronorCdeApi.SchemaMetadata {}

nonisolated public protocol KronorCdeApi_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == KronorCdeApi.SchemaMetadata {}

nonisolated public protocol KronorCdeApi_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == KronorCdeApi.SchemaMetadata {}

nonisolated public protocol KronorCdeApi_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == KronorCdeApi.SchemaMetadata {}

public extension KronorCdeApi {
  typealias SelectionSet = KronorCdeApi_SelectionSet

  typealias InlineFragment = KronorCdeApi_InlineFragment

  typealias MutableSelectionSet = KronorCdeApi_MutableSelectionSet

  typealias MutableInlineFragment = KronorCdeApi_MutableInlineFragment

  nonisolated enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    public static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    private static let objectTypeMap: [String: ApolloAPI.Object] = [
      "AuthorizeApplePayPaymentResult": KronorCdeApi.Objects.AuthorizeApplePayPaymentResult,
      "CustomerMutation": KronorCdeApi.Objects.CustomerMutation
    ]

    @_spi(Execution) public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
      objectTypeMap[typename]
    }
  }

  nonisolated enum Objects {}
  nonisolated enum Interfaces {}
  nonisolated enum Unions {}

}