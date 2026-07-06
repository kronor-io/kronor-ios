//
//  ApplePayButton.swift
//  kronor-ios
//

import SwiftUI
import PassKit

/// A native Apple Pay button (`PKPaymentButton`).
struct ApplePayButton: UIViewRepresentable {
    let action: @MainActor () -> Void

    func makeUIView(context: Context) -> PKPaymentButton {
        let button = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .automatic)
        button.addTarget(context.coordinator, action: #selector(Coordinator.tapped), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: PKPaymentButton, context: Context) {
        context.coordinator.action = action
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    @MainActor final class Coordinator: NSObject {
        var action: @MainActor () -> Void

        init(action: @escaping @MainActor () -> Void) {
            self.action = action
            super.init()
        }

        @objc func tapped() {
            action()
        }
    }
}
