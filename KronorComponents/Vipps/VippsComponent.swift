//
//  VippsComponent.swift
//  
//
//  Created by lorenzo on 2023-01-25.
//

import SwiftUI
import Kronor

/// A payment component that handles Vipps payments.
public struct VippsComponent: View {
    @StateObject private var viewModel: EmbeddedPaymentViewModel

    /// Creates a new Vipps payment component.
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
                paymentMethod: .vipps,
                paymentResultHandler: paymentResultHandler
            )
        )
    }

    public var body: some View {
        WrapperView(header: VippsHeaderView()) {
            EmbeddedPaymentView(
                viewModel: self.viewModel,
                waitingView: VippsWaitingView()
            )
        }
        .task {
            await viewModel.transition(.initialize)
        }
    }
}

struct VippsComponent_Previews: PreviewProvider {
    static var previews: some View {
        VippsComponent(
            configuration: Preview.configuration,
            paymentResultHandler: Preview.paymentResultHandler
        )
    }
}

