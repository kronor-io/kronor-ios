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
            if self.viewModel.state != .paymentCompleted && self.viewModel.state != .paymentRejected {
                await self.viewModel.transition(.waitForCancel)
            }
        }
    }

    func cancelNow() {
        Task {
            if self.viewModel.state != .paymentCompleted && self.viewModel.state != .paymentRejected {
                await self.viewModel.transition(.cancel)
            }
        }
    }

    func abortPayment() {
        Task {
            await self.viewModel.transition(.cancelFlow)
        }
    }

    var body: some View {
        self.innerBody
            .onOpenURL(perform: { url in
                Task {
                    let components = URLComponents(string: url.absoluteString)
                    let isCancel = components?.queryItems?.contains{ item in
                        item.name == "cancel"
                    }
                    if isCancel ?? false {
                        await self.viewModel.transition(.waitForCancel)
                    }
                }
            })
    }

    var innerBody: some View {
        switch viewModel.state {
        
        case .initializing, .creatingPaymentRequest, .waitingForPaymentRequest:
            return AnyView(self.waitingView)


        case .paymentRequestInitialized, .waitingForPayment:
            let keepOpen = Binding(
                get: {
                    if self.viewModel.embeddedSiteURL == nil {
                     return false
                    }

                    return self.webView.link != self.viewModel.returnURL
                },
                set: { _ in }
            )

            return AnyView(self.waitingView
                .sheet(isPresented: keepOpen, onDismiss: dismissSheet) {
                    if let url = self.viewModel.embeddedSiteURL {
                        EmbeddedSiteView(
                            webViewModel: self.webView,
                            url: url,
                            onCancel: cancelNow
                        )
                    }
                }.transition(.slide))


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
