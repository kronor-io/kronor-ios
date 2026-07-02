//
//  AvardaComponent.swift
//  KronorComponents
//

import SwiftUI
import Kronor

/// The buy-now-pay-later product used for an Avarda payment.
public enum BuyNowPayLaterProduct: String, Sendable, CaseIterable {
    case directInvoice = "DIRECT_INVOICE"
    case invoice = "INVOICE"
    case loan = "LOAN"
    case partPayment = "PART_PAYMENT"
}

/// A payment component that handles Avarda buy-now-pay-later payments.
///
/// The payment runs on Kronor's hosted payment page: it collects the
/// customer's national identification number, creates the payment, and
/// redirects to Avarda's checkout for identification.
public struct AvardaComponent: View {
    @StateObject private var viewModel: EmbeddedPaymentViewModel

    /// Creates a new Avarda payment component.
    /// - Parameters:
    ///   - configuration: The shared component configuration.
    ///   - buyNowPayLaterProduct: The Avarda product to pay with.
    ///   - paymentResultHandler: A closure called with the payment result.
    public init(
        configuration: ComponentConfiguration,
        buyNowPayLaterProduct: BuyNowPayLaterProduct = .directInvoice,
        paymentResultHandler: @escaping PaymentResultHandler
    ) {
        _viewModel = StateObject(
            wrappedValue: EmbeddedPaymentViewModel(
                configuration: configuration,
                stateMachine: EmbeddedPaymentStatechart.makeStateMachine(),
                networking: KronorEmbeddedPaymentNetworking(configuration: configuration),
                paymentMethod: .avarda,
                paymentResultHandler: paymentResultHandler,
                additionalQueryItems: [
                    URLQueryItem(name: "buyNowPayLaterProduct", value: buyNowPayLaterProduct.rawValue)
                ]
            )
        )
    }

    public var body: some View {
        WrapperView(header: AvardaHeaderView()) {
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

struct AvardaComponent_Previews: PreviewProvider {
    static var previews: some View {
        AvardaComponent(
            configuration: Preview.configuration,
            paymentResultHandler: Preview.paymentResultHandler
        )
    }
}
