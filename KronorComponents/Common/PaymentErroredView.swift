//
//  PaymentErroredView.swift
//
//

import SwiftUI

/// Shown when the payment flow lands in the errored state. Mirrors
/// ``PaymentRejectedView``: the customer can retry the payment or cancel and
/// go back to the checkout, so an unexpected error never leaves them stuck.
struct PaymentErroredView: View {
    var viewModel: RetryableModel

    @State var clickedOnSomething = false

    var body: some View {
        VStack {
            Spacer()
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
            .padding(.bottom)

            Spacer()
            if clickedOnSomething {
               Spacer()
            } else {
                Button(action: {
                    Task {
                        await viewModel.cancel()
                    }
                    clickedOnSomething = true
                }) {
                    Text(
                        "cancel",
                        bundle: .module,
                        comment: "Indicates that the user wants to cancel the payment session and go back to the checkout"
                    )
                }
                .padding(.vertical)

                Text("or", bundle: .module)
                    .font(.caption)

                Button(action: {
                    Task {
                        await viewModel.retry()
                    }
                    clickedOnSomething = true
                }) {
                    Text(
                        "try_again",
                        bundle: .module,
                        comment: "Indicates that the user wants to try the payment again"
                    )
                }
                .padding(.vertical)
            }
        }
    }
}

struct PaymentErroredView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentErroredView(viewModel: PreviewRetryable())
    }
}
