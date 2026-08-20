//
//  SwiftUIWebView.swift
//  
//
//  Created by lorenzo on 2023-01-19.
//

import SwiftUI
import WebKit

class WebViewModel: ObservableObject {
    /// The URL the webview last finished loading, or `nil` before the first
    /// navigation completes. Reset between presentations so a URL reached
    /// during an earlier attempt cannot decide anything about a later one.
    @Published var link: URL?
    @Published var didFinishLoading: Bool = false

    func reset() {
        self.link = nil
        self.didFinishLoading = false
    }
}

struct SwiftUIWebView: UIViewRepresentable {
    @ObservedObject var viewModel: WebViewModel
    var url: URL

    func makeUIView(context: UIViewRepresentableContext<SwiftUIWebView>) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        webView.allowsLinkPreview = false
        webView.load(URLRequest(url: self.url))

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<SwiftUIWebView>) {
        // SwiftUI may reuse the webview across body updates. Load again only
        // when it is showing something other than what we were asked for, so a
        // retry never leaves the customer looking at the previous attempt's
        // dead page.
        guard uiView.url != self.url, !uiView.isLoading else { return }
        uiView.load(URLRequest(url: self.url))
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
                     decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {

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
