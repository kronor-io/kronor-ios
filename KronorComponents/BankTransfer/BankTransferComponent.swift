//
//  BankTransferComponent.swift
//
//
//  Created by lorenzo on 2024-04-16.
//

import SwiftUI
import Kronor

public struct BankTransferComponent: View {
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
            paymentMethod: .bankTransfer,
            returnURL: returnURL,
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

struct BankTransferComponent_Previews: PreviewProvider {
    static var previews: some View {
        BankTransferComponent(
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
