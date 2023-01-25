//
//  EmbeddedPaymentView.swift
//  
//
//  Created by Jose-JORO on 2023-01-18.
//

import SwiftUI

struct EmbeddedPaymentView: View {
    @ObservedObject var viewModel: EmbeddedPaymentViewModel
    
    var waitingView: any View
    
    @ObservedObject var webView = WebViewModel()
    
    func dismissSheet() {
        Task {
            // wait to make sure that the closing of the sheet was not premature
            try await Task.sleep(nanoseconds: UInt64(0.3 * Double(NSEC_PER_SEC)))
            if self.viewModel.state != .paymentCompleted && self.viewModel.state != .paymentRejected {
                await self.viewModel.transition(.cancel)
                self.webView.link = URL(string: "https://kronor.io")!
            }
        }
    }

    var body: some View {
        switch viewModel.state {
        
        case .initializing, .creatingPaymentRequest, .waitingForPaymentRequest:
            return AnyView(self.waitingView)


        case .paymentRequestInitialized, .waitingForPayment:
            let keepOpen = Binding(
                get: {
                    if self.viewModel.embeddedSiteURL == nil {
                     return false
                    }
                    
                    let isKronorURL = self.webView.link.host?.hasSuffix("kronor.io") ?? false
                    let queryContainsFailure = self.webView.link.query?.contains("&failure=true") ?? false
                    return !(isKronorURL && queryContainsFailure)
                },
                set: { _ in }
            )

            return AnyView(self.waitingView
                .sheet(isPresented: keepOpen, onDismiss: dismissSheet) {
                    if let url = self.viewModel.embeddedSiteURL {
                        SwiftUIWebView(viewModel: self.webView, url: url)
                    }
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

struct EmbeddedPaymentView_Previews: PreviewProvider {
    static var previews: some View {
        let machine = EmbeddedPaymentStatechart.makeStateMachine()
        let viewModel = EmbeddedPaymentViewModel(
            env: .sandbox,
            sessionToken: "dummy",
            stateMachine: machine,
            paymentMethod: .mobilePay,
            returnURL: URL(string: "io.kronortest://")!,
            onPaymentFailure: {},
            onPaymentSuccess: {paymentId in }
        )
        WrapperView(header: Spacer()) {
            EmbeddedPaymentView(viewModel: viewModel, waitingView: MobilePayWaitingView())
                .previewDisplayName("prompt")
        }
    }
}
