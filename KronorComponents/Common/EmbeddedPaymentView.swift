//
//  EmbeddedPaymentView.swift
//
//
//  Created by Jose-JORO on 2023-01-18.
//

import SwiftUI

struct EmbeddedPaymentView<Content: View>: View {
    @ObservedObject private var embeddedPayViewModel: EmbeddedPaymentViewModel
    @ObservedObject private var webViewModel = WebViewModel()
    @State private var keepWaitingOpen = false
    private var waitingView: Content
    
    init (viewModel: EmbeddedPaymentViewModel, waitingView: Content) {
        self.embeddedPayViewModel = viewModel
        self.waitingView = waitingView
    }

    var body: some View {
        self.innerBody()
            .onOpenURL(perform: { url in
                Task {
                    let components = URLComponents(string: url.absoluteString)
                    let isCancel = components?.queryItems?.contains{ item in
                        item.name == "cancel"
                    }
                    if isCancel ?? false {
                        await self.embeddedPayViewModel.transition(.waitForCancel)
                    }
                }
            })
    }

    @ViewBuilder
    private func innerBody() -> some View {
        switch embeddedPayViewModel.state {
        case .initializing, .creatingPaymentRequest, .waitingForPaymentRequest:
            self.waitingView
        case .paymentRequestInitialized, .waitingForPayment:
            self.waitingView
                .transition(.slide)
                .onReceive(embeddedPayViewModel.$embeddedSiteURL.combineLatest(webViewModel.$link)) { (embeddedSiteURL, link) in
                        if let _ = embeddedSiteURL {
                            keepWaitingOpen = (link != embeddedPayViewModel.returnURL)
                        } else {
                            keepWaitingOpen = false
                        }
                }
                .sheet(isPresented: $keepWaitingOpen, onDismiss: dismissSheet) {
                    if let url = self.embeddedPayViewModel.embeddedSiteURL {
                        EmbeddedSiteView(
                            webViewModel: self.webViewModel,
                            url: url,
                            onCancel: cancelNow
                        )
                    }
                }
        case .paymentRejected:
            PaymentRejectedView(viewModel: self.embeddedPayViewModel)
        case .paymentCompleted:
            HStack {
                Spacer()
                Image(systemName: "checkmark.circle")
                    .foregroundColor(Color.green)
                
                Text(
                    "payment_completed",
                    bundle: .module,
                    comment:  "A success message indicating that the payment was completed and the payment session will end"
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
                    comment:  "An error message indicating there was an unexpected error with the payment"
                )
                .font(.headline)
                .foregroundColor(Color.red)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.all)
        }
    }
    
    private func dismissSheet() {
        Task {
            if self.embeddedPayViewModel.state != .paymentCompleted && self.embeddedPayViewModel.state != .paymentRejected {
                await self.embeddedPayViewModel.transition(.waitForCancel)
            }
        }
    }

    private func cancelNow() {
        Task {
            if self.embeddedPayViewModel.state != .paymentCompleted && self.embeddedPayViewModel.state != .paymentRejected {
                await self.embeddedPayViewModel.transition(.cancel)
            }
        }
    }

    private func abortPayment() {
        Task {
            await self.embeddedPayViewModel.transition(.cancelFlow)
        }
    }
}

struct EmbeddedPaymentView_Previews: PreviewProvider {
    static let viewModel = Preview.makeEmbeddedPaymentViewModel(paymentMethod: .mobilePay)
    
    static var previews: some View {
        WrapperView(header: Spacer()) {
            EmbeddedPaymentView(viewModel: viewModel, waitingView: MobilePayWaitingView())
                .previewDisplayName("prompt")
        }
    }
}
