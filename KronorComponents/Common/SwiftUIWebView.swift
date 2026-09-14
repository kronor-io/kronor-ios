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
    /// Identifies the attempt this presentation belongs to. A retry reuses the
    /// same session URL, so the attempt is the only thing that distinguishes a
    /// fresh start from an ongoing one.
    var attempt: Int

    /// Whether a body update should send the webview back to the payment site.
    ///
    /// SwiftUI may reuse the webview across body updates, so a retry has to be
    /// able to reload it. Deliberately decided from the attempt alone, and never
    /// from where the webview currently is: the customer navigates away from the
    /// session URL as a matter of course (to PayPal, to a bank), so reloading
    /// whenever the current URL differs would throw them back to the start of
    /// the flow on every body update.
    static func shouldLoad(attempt: Int, loadedAttempt: Int?) -> Bool {
        loadedAttempt != attempt
    }

    func makeUIView(context: UIViewRepresentableContext<SwiftUIWebView>) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        webView.allowsLinkPreview = false
        context.coordinator.loadedAttempt = self.attempt
        webView.load(URLRequest(url: self.url))

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<SwiftUIWebView>) {
        guard Self.shouldLoad(attempt: self.attempt, loadedAttempt: context.coordinator.loadedAttempt) else {
            return
        }
        context.coordinator.loadedAttempt = self.attempt
        uiView.load(URLRequest(url: self.url))
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        private var viewModel: WebViewModel
        /// The attempt this webview was last loaded for, as opposed to wherever
        /// the customer has navigated to since.
        var loadedAttempt: Int?

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
