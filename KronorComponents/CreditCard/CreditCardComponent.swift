//
//  CreditCardComponent.swift
//  
//
//  Created by lorenzo on 2023-01-23.
//

import SwiftUI
import Kronor

/// A payment component that handles credit card payments.
public struct CreditCardComponent: View {
    @StateObject private var viewModel: EmbeddedPaymentViewModel

    /// Creates a new credit card payment component.
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
                paymentMethod: .creditCard,
                paymentResultHandler: paymentResultHandler
            )
        )
    }

    public var body: some View {
        WrapperView(header: CreditCardHeaderView(viewModel: self.viewModel)) {
            EmbeddedPaymentView(viewModel: self.viewModel, waitingView: CreditCardWaitingView())
        }
        .task {
            await viewModel.transition(.initialize)
        }
    }
}

struct CreditCardComponent_Previews: PreviewProvider {
    static var previews: some View {
        CreditCardComponent(
            configuration: Preview.configuration,
            paymentResultHandler: Preview.paymentResultHandler
        )
    }
}
