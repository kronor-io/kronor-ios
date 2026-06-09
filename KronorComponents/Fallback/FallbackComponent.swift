//
//  FallbackComponent.swift
//
//
//  Created by lorenzo on 2023-01-17.
//

import SwiftUI
import Kronor

/// A generic payment component that handles payment methods without a dedicated component.
public struct FallbackComponent: View {
    @StateObject private var viewModel: EmbeddedPaymentViewModel

    /// Creates a new fallback payment component.
    /// - Parameters:
    ///   - configuration: The shared component configuration.
    ///   - paymentMethodName: The name of the payment method to use.
    ///   - paymentResultHandler: A closure called with the payment result.
    public init(
        configuration: ComponentConfiguration,
        paymentMethodName: String,
        paymentResultHandler: @escaping PaymentResultHandler
    ) {
        _viewModel = StateObject(
            wrappedValue: EmbeddedPaymentViewModel(
                configuration: configuration,
                stateMachine: EmbeddedPaymentStatechart.makeStateMachine(),
                networking: KronorEmbeddedPaymentNetworking(configuration: configuration),
                paymentMethod: .fallback(name: paymentMethodName),
                paymentResultHandler: paymentResultHandler
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

struct FallbackComponent_Previews: PreviewProvider {
    static var previews: some View {
        FallbackComponent(
            configuration: Preview.configuration,
            paymentMethodName: "swish",
            paymentResultHandler: Preview.paymentResultHandler
        )
    }
}
