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
                onPaymentFailure: @escaping (_ reason: FailureReason) -> (),
                onPaymentSuccess: @escaping (_ paymentId: String) -> ()
    ) {
        let machine = SwishStatechart.makeStateMachine()
        let networking = KronorSwishPaymentNetworking(
            env: env,
            token: sessionToken,
            device: device
        )
        self.viewModel = SwishPaymentViewModel(
            stateMachine: machine,
            networking: networking,
            returnURL: returnURL,
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
