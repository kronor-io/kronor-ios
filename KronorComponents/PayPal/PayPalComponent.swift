//
//  PayPalComponent.swift
//  
//
//  Created by lorenzo on 2023-01-26.
//

import SwiftUI
import Kronor

public struct PayPalComponent: View {
    let viewModel: EmbeddedPaymentViewModel
    
    public init(env: Kronor.Environment,
                sessionToken: String,
                returnURL: URL,
                device: Kronor.Device? = nil,
                onPaymentFailure: @escaping (_ reason: FailureReason) -> (),
                onPaymentSuccess: @escaping (_ paymentId: String) -> ()
    ) {
        let machine = EmbeddedPaymentStatechart.makeStateMachine()
        let networking = KronorEmbeddedPaymentNetworking(
            env: env,
            token: sessionToken,
            device: device
        )

        let viewModel = EmbeddedPaymentViewModel(
            env: env,
            sessionToken: sessionToken,
            stateMachine: machine,
            networking: networking,
            paymentMethod: .payPal,
            returnURL: returnURL,
            onPaymentFailure: onPaymentFailure,
            onPaymentSuccess: onPaymentSuccess
        )

        self.viewModel = viewModel

        Task {
            await viewModel.transition(.initialize)
        }
    }

    public var body: some View {
        WrapperView(header: PayPalHeaderView()) {
            EmbeddedPaymentView(
                viewModel: self.viewModel,
                waitingView: PayPalWaitingView()
            )
        }
    }
}

struct PayPalComponent_Previews: PreviewProvider {
    static var previews: some View {
        PayPalComponent(
            env: Preview.env,
            sessionToken: Preview.token,
            returnURL: Preview.returnURL,
            onPaymentFailure: { reason in
                print("failed: \(reason)")
            }
        ) { paymentId in
            print("done: \(paymentId)")
        }
    }
}
