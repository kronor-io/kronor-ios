// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) import ApolloAPI

public extension KronorCdeApi {
  /// Payment pass activation states.
  nonisolated enum ApplePayPaymentPassActivationStateEnum: String, EnumType {
    /// Active and ready to be used for payment.
    case activated = "activated"
    /// Not ready for use but activation is in progress.
    case activating = "activating"
    /// Not active because the issuer has disabled the account associated with the device.
    case deactivated = "deactivated"
    /// Not active but may be activated by the issuer.
    case requiresActivation = "requiresActivation"
    /// Not active and can’t be activated.
    case suspended = "suspended"
  }

}