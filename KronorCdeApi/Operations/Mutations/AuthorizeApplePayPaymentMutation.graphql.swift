// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension KronorCdeApi {
  nonisolated struct AuthorizeApplePayPaymentMutation: GraphQLMutation {
    public static let operationName: String = "AuthorizeApplePayPayment"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AuthorizeApplePayPayment($token: AuthorizeApplePayPaymentInput!) { authorizeApplePayPayment(token: $token) { __typename status maskedPan } }"#
      ))

    public var token: AuthorizeApplePayPaymentInput

    public init(token: AuthorizeApplePayPaymentInput) {
      self.token = token
    }

    @_spi(Unsafe) public var __variables: Variables? { ["token": token] }

    nonisolated public struct Data: KronorCdeApi.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorCdeApi.Objects.CustomerMutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("authorizeApplePayPayment", AuthorizeApplePayPayment.self, arguments: ["token": .variable("token")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AuthorizeApplePayPaymentMutation.Data.self
      ] }

      /// Authorize the Apple Pay payment
      public var authorizeApplePayPayment: AuthorizeApplePayPayment { __data["authorizeApplePayPayment"] }

      /// AuthorizeApplePayPayment
      ///
      /// Parent Type: `AuthorizeApplePayPaymentResult`
      nonisolated public struct AuthorizeApplePayPayment: KronorCdeApi.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { KronorCdeApi.Objects.AuthorizeApplePayPaymentResult }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("status", GraphQLEnum<KronorCdeApi.WalletAuthorizationResultEnum>.self),
          .field("maskedPan", String?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          AuthorizeApplePayPaymentMutation.Data.AuthorizeApplePayPayment.self
        ] }

        /// Returns "SUCCESS" when authorization succeeded or "TDS_REQUIRED" when the token needs a 3DS flow that is not handled by this mutation yet.
        public var status: GraphQLEnum<KronorCdeApi.WalletAuthorizationResultEnum> { __data["status"] }
        /// When status is "TDS_REQUIRED", this value may contain the last 4 digits of the selected card.
        public var maskedPan: String? { __data["maskedPan"] }
      }
    }
  }

}