//
//  PayPalPaymentView.swift
//  
//
//  Created by lorenzo on 2023-01-26.
//

import SwiftUI

struct PayPalPaymentView: View {
    @ObservedObject var viewModel: PayPalViewModel
    
    var body: some View {
        switch viewModel.state {

        case .initializing, .paymentRequestInitialized:
            return AnyView(PayPalWaitingView {
                Text(
                    "Creating secure PayPal transaction",
                    bundle: .module,
                    comment:  "A waiting message that indicates the app is communicating with the server"
                )
                .font(.subheadline)
            })

        case .waitingForPayment:
            return AnyView(PayPalWaitingView {
                Text(
                    "Completing your payment, please wait",
                    bundle: .module,
                    comment:  "A waiting message that indicates the app is finilizing the payment"
                )
                .font(.subheadline)
            })

        case .paymentRejected:
            return AnyView(
                PaymentRejectedView(viewModel: self.viewModel)
            )

            
        case .paymentCompleted:
            return AnyView(
                HStack {
                    Spacer()
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(Color.green)

                    Text(
                        "Payment completed",
                        bundle: .module,
                        comment:  "A success message indicating that the payment was completed and the payment session will end"
                    )
                    .font(.headline)
                    .foregroundColor(Color.green)

                    Spacer()
                }
            )

            
        case .errored(_):
            return AnyView(
                HStack {
                    Spacer()
                    Image(systemName: "xmark.circle")
                        .foregroundColor(Color.red)

                    Text(
                        "Could not complete the payment due to an error. Please try again after a short time",
                        bundle: .module,
                        comment:  "An error message indicating there was an unexpected error with the payment"
                    )
                    .font(.headline)
                    .foregroundColor(Color.red)
                    .padding(.horizontal)

                    Spacer()
                }
                    .padding(.all)
            )
        }
    }
}

struct PayPalPaymentView_Previews: PreviewProvider {
    static var previews: some View {
        let machine = PayPalStatechart.makeStateMachine()
        let viewModel = PayPalViewModel(
            env: .sandbox,
            sessionToken: "dummy",
            stateMachine: machine,
            returnURL: URL(string: "io.kronortest://")!,
            onPaymentFailure: {},
            onPaymentSuccess: {paymentId in }
        )
        WrapperView(header: Spacer()) {
            PayPalPaymentView(viewModel: viewModel)
                .previewDisplayName("prompt")
        }
    }
}
