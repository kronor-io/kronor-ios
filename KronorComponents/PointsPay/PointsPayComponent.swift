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
    ///   - loyaltyPrograms: Pointspay loyalty program codes to offer the
    ///     shopper, most preferred first, e.g. `["SAS", "FLB"]`. Pointspay only
    ///     offers the ones the merchant is connected to, and when exactly one
    ///     of them matches, the shopper skips Pointspay's program selection.
    ///     Currently valid codes are `SAS` (SAS EuroBonus), `FLB` (Flying
    ///     Blue), `MAM` (Miles & More), `ETHWL` (Etihad Guest) and `CBXL`
    ///     (Cashback XL). The full list is in the `program_hint` field of
    ///     Pointspay's payment API:
    ///     https://api.pointspay.com/v5/openapi/docs#/payment%20endpoints/process_payment_v5_payments_post
    ///     The codes are validated by the API, so new programs need no SDK
    ///     update. When empty, the shopper chooses among all the merchant's
    ///     programs.
    ///   - paymentResultHandler: A closure called with the payment result.
    public init(
        configuration: ComponentConfiguration,
        loyaltyPrograms: [String] = [],
        paymentResultHandler: @escaping PaymentResultHandler
    ) {
        _viewModel = StateObject(
            wrappedValue: EmbeddedPaymentViewModel(
                configuration: configuration,
                stateMachine: EmbeddedPaymentStatechart.makeStateMachine(),
                networking: KronorEmbeddedPaymentNetworking(configuration: configuration),
                paymentMethod: .pointsPay,
                paymentResultHandler: paymentResultHandler,
                prefersAuthenticationSession: true,
                additionalQueryItems: Self.queryItems(loyaltyPrograms: loyaltyPrograms)
            )
        )
    }

    /// The hosted page query items for the preferred loyalty programs, sent as
    /// comma-separated codes in order of preference. The codes are passed
    /// through as given and validated by the API. Blank codes are dropped
    /// rather than sent as empty entries, which the API rejects.
    static func queryItems(loyaltyPrograms: [String]) -> [URLQueryItem] {
        let codes = loyaltyPrograms.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        guard !codes.isEmpty else {
            return []
        }
        return [URLQueryItem(name: "loyaltyProgram", value: codes.joined(separator: ","))]
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
