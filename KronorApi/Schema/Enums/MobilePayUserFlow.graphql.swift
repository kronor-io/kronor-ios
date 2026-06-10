// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) import ApolloAPI

public extension KronorApi {
  /// How the end customer is expected to interact with MobilePay/Vipps
  nonisolated enum MobilePayUserFlow: String, EnumType {
    case nativeRedirect = "NativeRedirect"
    case pushMessage = "PushMessage"
    case qr = "QR"
    case webRedirect = "WebRedirect"
  }

}