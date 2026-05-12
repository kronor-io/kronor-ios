//
//  PointsPayComponent.swift
//  KronorComponents
//
//  Created by Tim Kofoed on 31/03/2026.
//

import SwiftUI
import Kronor

/// A payment component that handles PointsPay (EuroBonus) payments.
///
/// Uses `ASWebAuthenticationSession` instead of an embedded `WKWebView`
/// to bypass Cloudflare challenges that block `WKWebView`.
public struct PointsPayComponent: View {
    @StateObject private var viewModel: EmbeddedPaymentViewModel

    /// Creates a new PointsPay payment component.
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
                paymentMethod: .pointsPay,
                paymentResultHandler: paymentResultHandler,
                prefersAuthenticationSession: true
            )
        )
    }

    public var body: some View {
        WrapperView(header: FallbackHeaderView()) {
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

struct PointsPayComponent_Previews: PreviewProvider {
    static var previews: some View {
        PointsPayComponent(
            configuration: Preview.configuration,
            paymentResultHandler: Preview.paymentResultHandler
        )
    }
}
