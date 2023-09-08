//
//  CreditCardComponent.swift
//  
//
//  Created by lorenzo on 2023-01-23.
//

import SwiftUI
import Kronor

public struct CreditCardComponent: View {
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
            paymentMethod: .creditCard,
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
        WrapperView(header: CreditCardHeaderView(viewModel: self.viewModel)) {
            EmbeddedPaymentView(viewModel: self.viewModel, waitingView: CreditCardWaitingView())
        }
    }
}

struct CreditCardComponent_Previews: PreviewProvider {
    static var previews: some View {
        CreditCardComponent(
            env: Preview.env,
            sessionToken: Preview.token,
            returnURL: Preview.returnURL,
            onPaymentFailure: {
                print("failed!")
            }
        ) { paymentId in
            print("done: \(paymentId)")
        }
    }
}
