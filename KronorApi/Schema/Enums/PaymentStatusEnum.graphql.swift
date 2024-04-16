// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension KronorApi {
  enum PaymentStatusEnum: String, EnumType {
    /// Payment is ACCEPTED. Money is likely debited from the customer now. Wait for the PAID status before shipping the order
    case accepted = "ACCEPTED"
    /// Payment is authorized. Can be captured now.
    case authorized = "AUTHORIZED"
    /// Payment was cancelled.
    case cancelled = "CANCELLED"
    /// Attempting to cancel the payment.
    case cancelling = "CANCELLING"
    /// Payment capture is declined. Please create a new payment. (Only applicable for payments that support reservation)
    case captureDeclined = "CAPTURE_DECLINED"
    /// Payment was declined by the customer.
    case declined = "DECLINED"
    /// Payment errored.
    case error = "ERROR"
    /// Completed the frontend flow of a direct debit payment.
    case flowCompleted = "FLOW_COMPLETED"
    /// Payment is initialising.
    case initializing = "INITIALIZING"
    /// Payment is paid.
    case paid = "PAID"
    /// Payment is partially captured. (Only applicable for payments that support reservation)
    case partiallyCaptured = "PARTIALLY_CAPTURED"
    /// Payment is undergoing check.
    case preFlightCheck = "PRE_FLIGHT_CHECK"
    /// Payment reservation is released. (Only applicable for payments that support reservation)
    case released = "RELEASED"
    /// Payment is requested and waiting for confirmation.
    case waitingForPayment = "WAITING_FOR_PAYMENT"
    /// The payment request is being promoted to a payment
    case waitingForPromotion = "WAITING_FOR_PROMOTION"
  }

}