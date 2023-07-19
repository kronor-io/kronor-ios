//
//  MobilePayComponent.swift
//  
//
//  Created by lorenzo on 2023-01-17.
//

import SwiftUI
import Kronor

public struct MobilePayComponent: View {
    let viewModel: EmbeddedPaymentViewModel
    
    public init(env: Kronor.Environment,
                sessionToken: String,
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
            paymentMethod: .mobilePay,
            returnURL: returnURL,
            device: device,
            onPaymentFailure: onPaymentFailure,
            onPaymentSuccess: onPaymentSuccess
        )

        self.viewModel = viewModel

        Task {
            await viewModel.transition(.initialize)
        }
    }

    public var body: some View {
        WrapperView(header: MobilePayHeaderView()) {
            EmbeddedPaymentView(
                viewModel: self.viewModel,
                waitingView: MobilePayWaitingView()
            )
        }
    }
}

struct MobilePayComponent_Previews: PreviewProvider {
    static var previews: some View {
        MobilePayComponent(
            env: .sandbox,
            sessionToken: "dummy",
            returnURL: URL(string: "io.kronortest://")!,
            onPaymentFailure: {
                print("failed!")
            }
        ) {paymentId in
            print("done: \(paymentId)")
        }
    }
}
