// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension KronorApi {
  enum PaymentStatusEnum: String, EnumType {
    /// Payment is authorized. Can be captured now.
    case authorized = "AUTHORIZED"
    /// Payment was cancelled.
    case cancelled = "CANCELLED"
    /// Attempting to cancel the payment.
    case cancelling = "CANCELLING"
    /// Payment capture is declined. Please create a new payment. (Only applicable for credit card payments)
    case captureDeclined = "CAPTURE_DECLINED"
    /// Payment was declined by the customer.
    case declined = "DECLINED"
    /// Payment errored.
    case error = "ERROR"
    /// Payment is initialising.
    case initializing = "INITIALIZING"
    /// Payment is paid.
    case paid = "PAID"
    /// Payment is partially captured. (Only applicable for credit card payments)
    case partiallyCaptured = "PARTIALLY_CAPTURED"
    /// Payment is undergoing check.
    case preFlightCheck = "PRE_FLIGHT_CHECK"
    /// Payment is requested and waiting for confirmation.
    case waitingForPayment = "WAITING_FOR_PAYMENT"
  }

}