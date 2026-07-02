//
//  ApplePayPaymentView.swift
//  kronor-ios
//

import SwiftUI

struct ApplePayPaymentView: View {
    @ObservedObject var viewModel: ApplePayPaymentViewModel

    var body: some View {
        WrapperView(header: ApplePayHeaderView(), content: generateContentView)
    }

    @ViewBuilder func generateContentView() -> some View {
        switch viewModel.state {
        case .initializing, .creatingPaymentRequest, .waitingForPaymentRequest:
            HStack {
                Spacer()
                Image(systemName: "hourglass.circle")
                Text(
                    "creating_secure_transaction",
                    bundle: .module,
                    comment: "A waiting message that indicates the app is communicating with the server"
                )
                .font(.subheadline)
                Spacer()
            }
        case .notAvailable:
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "xmark.circle")
                    Text(
                        "apple_pay_not_available",
                        bundle: .module,
                        comment: "Indicates that Apple Pay is not available on this device"
                    )
                    .font(.subheadline)
                    Spacer()
                }
                .padding(.bottom)

                Button(action: {
                    Task {
                        await viewModel.cancel()
                    }
                }) {
                    Text(
                        "cancel",
                        bundle: .module,
                        comment: "Indicates that the user wants to cancel the payment session and go back to the checkout"
                    )
                }
            }
        case .paymentReady, .authorizing:
            HStack {
                Spacer()
                ApplePayButton {
                    Task {
                        await viewModel.transition(.payButtonTapped)
                    }
                }
                .frame(width: 220, height: 48)
                .disabled(viewModel.state == .authorizing)
                Spacer()
            }
        case .waitingForSheetDismissal, .waitingForPayment:
            HStack {
                Spacer()
                Image(systemName: "hourglass.circle")
                Text(
                    "completing_payment",
                    bundle: .module,
                    comment: "A waiting message indicating that the payment is being finalized"
                )
                .font(.subheadline)
                Spacer()
            }
        case .paymentRejected:
            PaymentRejectedView(viewModel: self.viewModel)
        case .paymentCompleted:
            HStack {
                Spacer()
                Image(systemName: "checkmark.circle")
                    .foregroundColor(Color.green)

                Text(
                    "payment_completed",
                    bundle: .module,
                    comment: "A success message indicating that the payment was completed and the payment session will end"
                )
                .font(.headline)
                .foregroundColor(Color.green)

                Spacer()
            }
        case .errored(_):
            HStack {
                Spacer()
                Image(systemName: "xmark.circle")
                    .foregroundColor(Color.red)

                Text(
                    "payment_error_retry_later",
                    bundle: .module,
                    comment: "An error message indicating there was an unexpected error with the payment"
                )
                .font(.headline)
                .foregroundColor(Color.red)

                Spacer()
            }
        }
    }
}
