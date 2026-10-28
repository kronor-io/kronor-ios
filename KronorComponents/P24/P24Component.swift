//
//  P24Component.swift
//
//
//  Created by lorenzo on 2024-07-08.
//

import SwiftUI
import Kronor

/// A Przelewy24 channel that can be offered on its own, in place of the
/// merchant's configured channels.
///
/// Mirrors the `P24PaymentChannel` GraphQL enum. Channels added to the API
/// before the SDK knows about them can be used with `init(rawValue:)`.
public struct P24PaymentChannel: RawRepresentable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Only bank transfers are offered. P24 includes BLIK in this group.
    public static let bankTransfers = P24PaymentChannel(rawValue: "BANK_TRANSFERS")
    /// Only BLIK is offered.
    public static let blik = P24PaymentChannel(rawValue: "BLIK")
}

/// A payment component that handles Przelewy24 (P24) payments.
public struct P24Component: View {
    @StateObject private var viewModel: EmbeddedPaymentViewModel

    /// Creates a new P24 payment component.
    /// - Parameters:
    ///   - configuration: The shared component configuration.
    ///   - channelOverride: The channel to offer instead of the merchant's
    ///     configured channels, e.g. `.blik` to offer only BLIK. When `nil`,
    ///     the merchant's configured channels are used.
    ///   - paymentResultHandler: A closure called with the payment result.
    public init(
        configuration: ComponentConfiguration,
        channelOverride: P24PaymentChannel? = nil,
        paymentResultHandler: @escaping PaymentResultHandler
    ) {
        _viewModel = StateObject(
            wrappedValue: EmbeddedPaymentViewModel(
                configuration: configuration,
                stateMachine: EmbeddedPaymentStatechart.makeStateMachine(),
                networking: KronorEmbeddedPaymentNetworking(configuration: configuration),
                paymentMethod: .p24,
                paymentResultHandler: paymentResultHandler,
                additionalQueryItems: Self.queryItems(channelOverride: channelOverride)
            )
        )
    }

    /// The hosted page query items for a channel override. An empty raw value
    /// is treated as no override rather than sent as an invalid channel.
    static func queryItems(channelOverride: P24PaymentChannel?) -> [URLQueryItem] {
        guard let channel = channelOverride?.rawValue, !channel.isEmpty else {
            return []
        }
        return [URLQueryItem(name: "channelOverride", value: channel)]
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

struct P24Component_Previews: PreviewProvider {
    static var previews: some View {
        P24Component(
            configuration: Preview.configuration,
            paymentResultHandler: Preview.paymentResultHandler
        )
    }
}
