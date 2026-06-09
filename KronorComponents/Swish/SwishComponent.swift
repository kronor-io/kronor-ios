//
//  SwishComponent.swift
//  kronor-ios
//
//  Created by lorenzo on 2023-01-10.
//

import SwiftUI
import Kronor

/// A payment component that handles Swish payments.
public struct SwishComponent: View {
    @StateObject private var viewModel: SwishPaymentViewModel

    /// Creates a new Swish payment component.
    /// - Parameters:
    ///   - configuration: The shared component configuration.
    ///   - paymentResultHandler: A closure called with the payment result.
    public init(
        configuration: ComponentConfiguration,
        paymentResultHandler: @escaping PaymentResultHandler
    ) {
        _viewModel = StateObject(
            wrappedValue: SwishPaymentViewModel(
                stateMachine: SwishStatechart.makeStateMachine(),
                networking: KronorSwishPaymentNetworking(configuration: configuration),
                returnURL: configuration.returnURL,
                paymentResultHandler: paymentResultHandler
            )
        )
    }

    public var body: some View {
        SwishPaymentView(viewModel: self.viewModel)
    }
}

struct SwishComponent_Previews: PreviewProvider {
    static var previews: some View {
        SwishComponent(
            configuration: Preview.configuration,
            paymentResultHandler: Preview.paymentResultHandler
        )
    }
}
