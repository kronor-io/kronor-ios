//
//  SwiftUIWebView.swift
//  
//
//  Created by lorenzo on 2023-01-19.
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
        self.webView.allowsBackForwardNavigationGestures = false
        self.webView.allowsLinkPreview = false
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

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

            // if the url is not http(s) schema, then the UIApplication open the url
            if let url = navigationAction.request.url,
               let scheme = url.scheme,
               scheme != "http",
               scheme != "https" {

                UIApplication.shared.open(url)

                // cancel the request
                decisionHandler(.cancel)
            } else {
                // allow the request
                decisionHandler(.allow)
            }
        }
    }

    func makeCoordinator() -> SwiftUIWebView.Coordinator {
        Coordinator(viewModel)
    }
}
