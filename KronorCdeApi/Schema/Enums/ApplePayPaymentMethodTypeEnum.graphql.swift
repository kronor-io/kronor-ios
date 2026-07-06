// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) import ApolloAPI

public extension KronorCdeApi {
  /// The type of card the customer uses to complete the transaction.
  nonisolated enum ApplePayPaymentMethodTypeEnum: String, EnumType {
    /// CREDIT
    case credit = "credit"
    /// DEBIT
    case debit = "debit"
    /// PREPAID
    case prepaid = "prepaid"
    /// STORE
    case store = "store"
  }

}