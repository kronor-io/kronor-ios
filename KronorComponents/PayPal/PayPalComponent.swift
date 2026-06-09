//
//  PayPalComponent.swift
//  
//
//  Created by lorenzo on 2023-01-26.
//

import SwiftUI
import Kronor

/// A payment component that handles PayPal payments.
public struct PayPalComponent: View {
    @StateObject private var viewModel: EmbeddedPaymentViewModel

    /// Creates a new PayPal payment component.
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
                paymentMethod: .payPal,
                paymentResultHandler: paymentResultHandler
            )
        )
    }

    public var body: some View {
        WrapperView(header: PayPalHeaderView()) {
            EmbeddedPaymentView(
                viewModel: self.viewModel,
                waitingView: PayPalWaitingView()
            )
        }
        .task {
            await viewModel.transition(.initialize)
        }
    }
}

struct PayPalComponent_Previews: PreviewProvider {
    static var previews: some View {
        PayPalComponent(
            configuration: Preview.configuration,
            paymentResultHandler: Preview.paymentResultHandler
        )
    }
}
