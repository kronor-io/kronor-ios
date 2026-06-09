//
//  MobilePayComponent.swift
//  
//
//  Created by lorenzo on 2023-01-17.
//

import SwiftUI
import Kronor

/// A payment component that handles MobilePay payments.
public struct MobilePayComponent: View {
    @StateObject private var viewModel: EmbeddedPaymentViewModel

    /// Creates a new MobilePay payment component.
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
                paymentMethod: .mobilePay,
                paymentResultHandler: paymentResultHandler
            )
        )
    }

    public var body: some View {
        WrapperView(header: MobilePayHeaderView()) {
            EmbeddedPaymentView(
                viewModel: self.viewModel,
                waitingView: MobilePayWaitingView()
            )
        }
        .task {
            await viewModel.transition(.initialize)
        }
    }
}

struct MobilePayComponent_Previews: PreviewProvider {
    static var previews: some View {
        MobilePayComponent(
            configuration: Preview.configuration,
            paymentResultHandler: Preview.paymentResultHandler
        )
    }
}
