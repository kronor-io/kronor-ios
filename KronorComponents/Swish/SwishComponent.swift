//
//  SwishComponent.swift
//  kronor-test-app
//
//  Created by Jose-JORO on 2023-01-10.
//

import SwiftUI

public struct SwishComponent: View {
    private var viewModel: SwishPaymentViewModel
    
    init(sessionToken: String,
         returnURL: URL,
         onPaymentFailure: @escaping () -> (),
         onPaymentSuccess: @escaping (_ paymentId: String) -> ()
    ) {
        let machine = SwishStatechart.makeStateMachine()
        self.viewModel = SwishPaymentViewModel(
            sessionToken: sessionToken,
            stateMachine: machine,
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
