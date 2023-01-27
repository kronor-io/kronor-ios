//
//  PayPalComponent.swift
//  
//
//  Created by lorenzo on 2023-01-26.
//

import SwiftUI
import Kronor

public struct PayPalComponent: View {
    let viewModel: PayPalViewModel
    
    public init(env: Kronor.Environment,
                sessionToken: String,
                returnURL: URL,
                device: Kronor.Device? = nil,
                onPaymentFailure: @escaping () -> (),
                onPaymentSuccess: @escaping (_ paymentId: String) -> ()
    ) {
        let machine = PayPalStatechart.makeStateMachine()

        let viewModel = PayPalViewModel(
            env: env,
            sessionToken: sessionToken,
            stateMachine: machine,
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
        WrapperView(header: PayPalHeaderView()) {
            PayPalPaymentView(
                viewModel: self.viewModel
            )
        }
    }
}

struct PayPalComponent_Previews: PreviewProvider {
    static var previews: some View {
        PayPalComponent(
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
