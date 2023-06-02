// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension KronorApi {
  class BraintreeSettingQuery: GraphQLQuery {
    public static let operationName: String = "BraintreeSetting"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query BraintreeSetting {
          braintreeSetting {
            __typename
            tokenizationKey
            paypalClientId
            currency
          }
        }
        """#
      ))

    public init() {}

    public struct Data: KronorApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KronorApi.Objects.Query_root }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("braintreeSetting", [BraintreeSetting].self),
      ] }

      /// fetch data from the table: "tenant.braintree_setting"
      public var braintreeSetting: [BraintreeSetting] { __data["braintreeSetting"] }

      /// BraintreeSetting
      ///
      /// Parent Type: `BraintreeSetting`
      public struct BraintreeSetting: KronorApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KronorApi.Objects.BraintreeSetting }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("tokenizationKey", String.self),
          .field("paypalClientId", String.self),
          .field("currency", GraphQLEnum<KronorApi.SupportedCurrencyEnum>.self),
        ] }

        public var tokenizationKey: String { __data["tokenizationKey"] }
        public var paypalClientId: String { __data["paypalClientId"] }
        public var currency: GraphQLEnum<KronorApi.SupportedCurrencyEnum> { __data["currency"] }
      }
    }
  }

}