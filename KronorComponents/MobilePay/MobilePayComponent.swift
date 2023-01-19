//
//  MobilePayComponent.swift
//  
//
//  Created by Jose-JORO on 2023-01-17.
//

import SwiftUI
import Kronor

public struct MobilePayComponent: View {
    let viewModel: MobilePayViewModel
    
    public init(sessionToken: String,
                returnURL: URL,
                device: Kronor.Device? = nil,
                onPaymentFailure: @escaping () -> (),
                onPaymentSuccess: @escaping (_ paymentId: String) -> ()
    ) {
        let machine = EmbeddedPaymentStatechart.makeStateMachine()

        let viewModel = MobilePayViewModel(
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
        MobilePayPaymentView(viewModel: self.viewModel)
    }
}

struct MobilePayComponent_Previews: PreviewProvider {
    static var previews: some View {
        MobilePayComponent(
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
