//
//  MobilePayPaymentView.swift
//  
//
//  Created by Jose-JORO on 2023-01-18.
//

import SwiftUI
import WebKit

class WebViewModel: ObservableObject {
    @Published var link = URL(string: "https://kronor.io")!
    @Published var didFinishLoading: Bool = false
}

struct SwiftUIWebView: UIViewRepresentable {
    @ObservedObject var viewModel: WebViewModel
    var url: URL

    let webView = WKWebView()

    func makeUIView(context: UIViewRepresentableContext<SwiftUIWebView>) -> WKWebView {
        self.webView.navigationDelegate = context.coordinator
        self.webView.load(URLRequest(url: self.url))
        return self.webView
    }

    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<SwiftUIWebView>) {
        return
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        private var viewModel: WebViewModel

        init(_ viewModel: WebViewModel) {
            self.viewModel = viewModel
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if let url = webView.url {
                self.viewModel.link = url
            }
            self.viewModel.didFinishLoading = true
        }
    }

    func makeCoordinator() -> SwiftUIWebView.Coordinator {
        Coordinator(viewModel)
    }
}

struct MobilePayWaitingView: View {
    var body: some View {
        MobilePayWrapperView {
            HStack {
                Spacer()
                Image(systemName: "hourglass.circle")
                Text(
                    "Creating secure MobilePay transaction",
                    bundle: .module,
                    comment:  "A waiting message that indicates the app is communicating with the server"
                )
                    .font(.subheadline)
                Spacer()
            }
        }
    }
}

struct MobilePayPaymentView: View {
    @ObservedObject var viewModel: MobilePayViewModel
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
            return AnyView(MobilePayWaitingView())


        case .paymentRequestInitialized, .waitingForPayment:
            let keepOpen = Binding(
                get: {
                    print("new URL: \(self.webView.link)")
                    if self.viewModel.embeddedSiteURL == nil {
                     return false
                    }
                    
                    let isKronorURL = self.webView.link.host?.hasSuffix("kronor.io") ?? false
                    let queryContainsFailure = self.webView.link.query?.contains("&failure=true") ?? false
                    return !(isKronorURL && queryContainsFailure)
                },
                set: { _ in }
            )

            return AnyView(MobilePayWaitingView()
                .sheet(isPresented: keepOpen, onDismiss: dismissSheet) {
                    if let url = self.viewModel.embeddedSiteURL {
                        SwiftUIWebView(viewModel: self.webView, url: url)
                    }
                })


        case .paymentRejected:
            return AnyView(MobilePayWrapperView {
                PaymentRejectedView(viewModel: self.viewModel)
            })

            
        case .paymentCompleted:
            return AnyView(MobilePayWrapperView {
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
            })

            
        case .errored(_):
            return AnyView(MobilePayWrapperView {
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

                    Spacer()
                }
            })
        }
    }
}

struct MobilePayPaymentView_Previews: PreviewProvider {
    static var previews: some View {
        let machine = EmbeddedPaymentStatechart.makeStateMachine()
        let viewModel = MobilePayViewModel(
            sessionToken: "dummy",
            stateMachine: machine,
            returnURL: URL(string: "io.kronortest://")!,
            onPaymentFailure: {},
            onPaymentSuccess: {paymentId in }
        )
        MobilePayPaymentView(viewModel: viewModel)
            .previewDisplayName("prompt")
    }
}
