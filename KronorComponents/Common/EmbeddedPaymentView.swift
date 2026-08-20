//
//  EmbeddedPaymentView.swift
//
//
//  Created by Jose-JORO on 2023-01-18.
//

import SwiftUI
import AuthenticationServices

struct EmbeddedPaymentView<Content: View>: View {
    @ObservedObject private var embeddedPayViewModel: EmbeddedPaymentViewModel
    @ObservedObject private var webViewModel = WebViewModel()
    @State private var presentedSite: EmbeddedPaymentViewModel.EmbeddedSite?
    @State private var siteIntentionallyClosed = false
    @State private var showAuthSession = false
    @State private var authSessionIntentionallyClosed = false
    private var waitingView: Content
    
    init (viewModel: EmbeddedPaymentViewModel, waitingView: Content) {
        self.embeddedPayViewModel = viewModel
        self.waitingView = waitingView
    }

    var body: some View {
        self.innerBody()
            .onOpenURL(perform: { url in
                // only react to redirect-returns on the configured return URL,
                // not to unrelated deep links received while this view is shown
                guard url.scheme == embeddedPayViewModel.returnURL.scheme else { return }
                handleRedirectReturn(url: url)
            })
    }

    @ViewBuilder
    private func innerBody() -> some View {
        switch embeddedPayViewModel.state {
        case .initializing, .creatingPaymentRequest, .waitingForPaymentRequest, .paymentRequestInitialized, .waitingForPayment:
            if embeddedPayViewModel.prefersAuthenticationSession {
                self.waitingView
                    .paymentDelayedNotice(embeddedPayViewModel.isDelayed)
                    .transition(.slide)
                    .onReceive(embeddedPayViewModel.$embeddedSite) { embeddedSite in
                        showAuthSession = embeddedSite != nil
                    }
                    .fullScreenCover(isPresented: $showAuthSession, onDismiss: onAuthSessionDismissed) {
                        if let url = self.embeddedPayViewModel.embeddedSite?.url,
                           let scheme = embeddedPayViewModel.returnURL.scheme {
                            AuthSessionViewRepresentable(
                                url: url,
                                callbackScheme: scheme,
                                onComplete: dismissAuthSession,
                                onCancel: cancelNow
                            )
                        }
                    }
            } else {
                self.waitingView
                    .paymentDelayedNotice(embeddedPayViewModel.isDelayed)
                    .transition(.slide)
                    .onReceive(embeddedPayViewModel.$embeddedSite.combineLatest(webViewModel.$link)) { (embeddedSite, link) in
                        guard let embeddedSite, link != embeddedPayViewModel.returnURL else {
                            return closeSite()
                        }
                        // A new attempt gets a new identifier, which rebuilds
                        // the sheet and its webview even though the URL is
                        // unchanged. The webview also starts from a clean slate,
                        // so the previous attempt's last URL cannot immediately
                        // close the new sheet.
                        guard presentedSite?.id != embeddedSite.id else { return }
                        // Adopt the new attempt before clearing the webview
                        // state: resetting publishes back into this same
                        // pipeline, and the identifier check above is what stops
                        // it from looping.
                        presentedSite = embeddedSite
                        if link != nil {
                            webViewModel.reset()
                        }
                    }
                    .sheet(item: $presentedSite, onDismiss: onSiteDismissed) { site in
                        EmbeddedSiteView(
                            webViewModel: self.webViewModel,
                            url: site.url,
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
            PaymentErroredView(viewModel: self.embeddedPayViewModel)
        }
    }
    
    private func dismissAuthSession(callbackURL: URL?) {
        authSessionIntentionallyClosed = true
        showAuthSession = false
        // the auth session completed by hitting the return URL scheme, which
        // means the customer was redirected back from the payment provider
        handleRedirectReturn(url: callbackURL)
    }

    private func handleRedirectReturn(url: URL?) {
        let components = url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
        let isCancel = components?.queryItems?.contains { item in
            item.name == "cancel"
        } ?? false

        if isCancel {
            Task {
                await self.embeddedPayViewModel.transition(.waitForCancel)
            }
        } else {
            self.embeddedPayViewModel.refreshPaymentStatus()
        }
    }

    /// Closes the embedded site without the dismissal being mistaken for the
    /// customer swiping the sheet away, which would cancel the payment.
    private func closeSite() {
        guard presentedSite != nil else { return }
        siteIntentionallyClosed = true
        presentedSite = nil
    }

    private func onSiteDismissed() {
        defer { siteIntentionallyClosed = false }
        guard !siteIntentionallyClosed else { return }
        dismissSheet()
    }

    private func onAuthSessionDismissed() {
        defer { authSessionIntentionallyClosed = false }
        guard !authSessionIntentionallyClosed else { return }
        dismissSheet()
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
