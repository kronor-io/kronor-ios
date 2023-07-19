//
//  SwishComponent.swift
//  kronor-ios
//
//  Created by lorenzo on 2023-01-10.
//

import SwiftUI
import Kronor

public struct SwishComponent: View {
    let viewModel: SwishPaymentViewModel
    
    public init(env: Kronor.Environment,
                sessionToken: String,
                returnURL: URL,
                device: Kronor.Device? = nil,
                onPaymentFailure: @escaping () -> (),
                onPaymentSuccess: @escaping (_ paymentId: String) -> ()
    ) {
        let machine = SwishStatechart.makeStateMachine()
        let networking = KronorSwishPaymentNetworking(
            env: env,
            token: sessionToken
        )
        self.viewModel = SwishPaymentViewModel(
            stateMachine: machine,
            networking: networking,
            returnURL: returnURL,
            device: device,
            onPaymentFailure: onPaymentFailure,
            onPaymentSuccess: onPaymentSuccess
        )

    }

    public var body: some View {
        SwishPaymentView(viewModel: self.viewModel)
    }
}

struct SwishComponent_Previews: PreviewProvider {
    static var previews: some View {
        SwishComponent(
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
