//
//  GooglePayComponent.swift
//  KronorComponents
//

import SwiftUI
import Kronor

/// A payment component that handles Google Pay payments.
///
/// Google Pay has no native iOS SDK, so the payment runs on Kronor's hosted
/// payment page. It is presented with `ASWebAuthenticationSession` rather
/// than an embedded `WKWebView` because the Google Pay web API rejects
/// WebViews (`isReadyToPay` is always false there), while the
/// authentication session is a real Safari context with access to the
/// customer's Google account.
public struct GooglePayComponent: View {
    @StateObject private var viewModel: EmbeddedPaymentViewModel

    /// Creates a new Google Pay payment component.
    /// - Parameters:
    ///   - configuration: The shared component configuration.
    ///   - paymentResultHandler: A closure called with the payment result.
    public init(
        configuration: ComponentConfiguration,
        paymentResultHandler: @escaping PaymentResultHandler
    ) {
        _viewModel = StateObject(
            wrappedValue: EmbeddedPaymentViewModel(
                configuration: configuration,
                stateMachine: EmbeddedPaymentStatechart.makeStateMachine(),
                networking: KronorEmbeddedPaymentNetworking(configuration: configuration),
                paymentMethod: .googlePay,
                paymentResultHandler: paymentResultHandler,
                prefersAuthenticationSession: true
            )
        )
    }

    public var body: some View {
        WrapperView(header: GooglePayHeaderView()) {
            EmbeddedPaymentView(
                viewModel: self.viewModel,
                waitingView: FallbackWaitingView()
            )
        }
        .task {
            await viewModel.initialize()
        }
    }
}

struct GooglePayComponent_Previews: PreviewProvider {
    static var previews: some View {
        GooglePayComponent(
            configuration: Preview.configuration,
            paymentResultHandler: Preview.paymentResultHandler
        )
    }
}
