//
//  PaymentDelayedView.swift
//
//

import SwiftUI

/// A small notice shown while the SDK is silently retrying transient
/// failures, so the customer knows the payment is taking longer than usual
/// and is still in progress.
struct PaymentDelayedView: View {
    var body: some View {
        HStack(spacing: 8) {
            Spacer()
            ProgressView()
                .controlSize(.small)
            Text(
                "payment_taking_longer",
                bundle: .module,
                comment: "Tells the customer that the payment is taking longer than usual but is still being processed"
            )
            .font(.footnote)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

/// Attaches a ``PaymentDelayedView`` under the content, fading it in and out
/// as the view model reports delays.
struct PaymentDelayedModifier: ViewModifier {
    var isDelayed: Bool

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content
            if isDelayed {
                PaymentDelayedView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isDelayed)
    }
}

extension View {
    func paymentDelayedNotice(_ isDelayed: Bool) -> some View {
        modifier(PaymentDelayedModifier(isDelayed: isDelayed))
    }
}

struct PaymentDelayedView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentDelayedView()
    }
}
