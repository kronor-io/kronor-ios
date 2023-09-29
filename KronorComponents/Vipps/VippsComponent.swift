//
//  VippsComponent.swift
//  
//
//  Created by lorenzo on 2023-01-25.
//

import SwiftUI
import Kronor

public struct VippsComponent: View {
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
            token: sessionToken
        )
        let viewModel = EmbeddedPaymentViewModel(
            env: env,
            sessionToken: sessionToken,
            stateMachine: machine,
            networking: networking,
            paymentMethod: .vipps,
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
        WrapperView(header: VippsHeaderView()) {
            EmbeddedPaymentView(
                viewModel: self.viewModel,
                waitingView: VippsWaitingView()
            )
        }
    }
}

struct VippsComponent_Previews: PreviewProvider {
    static var previews: some View {
        VippsComponent(
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

