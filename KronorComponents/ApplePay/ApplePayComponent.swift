//
//  ApplePayComponent.swift
//  kronor-ios
//

import SwiftUI
import PassKit
import Kronor

/// A payment component that handles native (in-app) Apple Pay payments.
///
/// The host app is responsible for the `com.apple.developer.in-app-payments`
/// entitlement and for registering the merchant identifier with Apple.
public struct ApplePayComponent: View {
    @StateObject private var viewModel: ApplePayPaymentViewModel

    /// Creates a new Apple Pay payment component.
    /// - Parameters:
    ///   - configuration: The shared component configuration.
    ///   - merchantIdentifier: The Apple Pay merchant identifier registered in the
    ///     merchant's Apple developer account.
    ///   - merchantName: The business name shown in the payment sheet summary.
    ///   - supportedNetworks: The card networks accepted for the payment.
    ///   - countryCode: The two-letter ISO 3166 country code of the merchant.
    ///     Defaults to the device region.
    ///   - paymentResultHandler: A closure called with the payment result.
    public init(
        configuration: ComponentConfiguration,
        merchantIdentifier: String,
        merchantName: String,
        supportedNetworks: [PKPaymentNetwork] = [.visa, .masterCard, .amex],
        countryCode: String? = nil,
        paymentResultHandler: @escaping PaymentResultHandler
    ) {
        _viewModel = StateObject(
            wrappedValue: ApplePayPaymentViewModel(
                stateMachine: ApplePayStatechart.makeStateMachine(),
                networking: KronorApplePayPaymentNetworking(configuration: configuration),
                returnURL: configuration.returnURL,
                merchantIdentifier: merchantIdentifier,
                merchantName: merchantName,
                supportedNetworks: supportedNetworks,
                countryCode: countryCode,
                paymentResultHandler: paymentResultHandler
            )
        )
    }

    /// True when the device is able to make Apple Pay payments with one of the
    /// supported networks. Use this to decide whether to offer Apple Pay as a
    /// payment method.
    public static func canMakePayments(
        usingNetworks networks: [PKPaymentNetwork] = [.visa, .masterCard, .amex]
    ) -> Bool {
        ApplePayPaymentViewModel.canMakePayments(usingNetworks: networks)
    }

    public var body: some View {
        ApplePayPaymentView(viewModel: self.viewModel)
            .task {
                await viewModel.initialize()
            }
    }
}
