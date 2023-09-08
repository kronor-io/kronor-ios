//
//  FallbackComponent.swift
//
//
//  Created by lorenzo on 2023-01-17.
//

import SwiftUI
import Kronor

public struct FallbackComponent: View {
    let viewModel: EmbeddedPaymentViewModel
    
    public init(env: Kronor.Environment,
                sessionToken: String,
                paymentMethodName: String,
                returnURL: URL,
                device: Kronor.Device? = nil,
                onPaymentFailure: @escaping () -> (),
                onPaymentSuccess: @escaping (_ paymentId: String) -> ()
    ) {
        let machine = EmbeddedPaymentStatechart.makeStateMachine()
        let networking = KronorEmbeddedPaymentNetworking(
            env: env,
            token: sessionToken
        )
        let viewModel = EmbeddedPaymentViewModel(
            env: env,
            sessionToken: sessionToken,
            stateMachine: machine,
            networking: networking,
            paymentMethod: .fallback(name: paymentMethodName),
            returnURL: returnURL,
            device: device,
            onPaymentFailure: onPaymentFailure,
            onPaymentSuccess: onPaymentSuccess
        )

        self.viewModel = viewModel

        Task {
            await viewModel.initialize()
        }
    }

    public var body: some View {
        WrapperView(header: FallbackHeaderView()) {
            EmbeddedPaymentView(
                viewModel: self.viewModel,
                waitingView: FallbackWaitingView()
            )
        }
    }
}

struct FallbackComponent_Previews: PreviewProvider {
    static var previews: some View {
        FallbackComponent(
            env: Preview.env,
            sessionToken: Preview.token,
            paymentMethodName: "swish",
            returnURL: Preview.returnURL,
            onPaymentFailure: {
                print("failed!")
            }
        ) { paymentId in
            print("done: \(paymentId)")
        }
    }
}
