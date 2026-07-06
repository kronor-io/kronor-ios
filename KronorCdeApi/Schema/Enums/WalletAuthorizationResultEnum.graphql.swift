// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) import ApolloAPI

public extension KronorCdeApi {
  /// The status value of a wallet authorization result
  nonisolated enum WalletAuthorizationResultEnum: String, EnumType {
    /// Authorization successful
    case success = "SUCCESS"
    /// 3ds is required for this payment
    case tdsRequired = "TDS_REQUIRED"
  }

}