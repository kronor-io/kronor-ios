//
//  CreditCardWaitingView.swift
//
//
//  Created by lorenzo on 2023-01-24.
//

import SwiftUI

struct CreditCardWaitingView: View {
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "hourglass.circle")
            Text(
                "secure_connection",
                bundle: .module,
                comment:  "A waiting message that indicates the app is communicating with the server"
            )
                .font(.subheadline)
            Spacer()
        }
    }
}

struct CreditCardWaitingView_Previews: PreviewProvider {
    static var previews: some View {
        let machine = EmbeddedPaymentStatechart.makeStateMachine()
        let viewModel = EmbeddedPaymentViewModel(
            env: .sandbox,
            sessionToken: "dummy",
            stateMachine: machine,
            networking: KronorEmbeddedPaymentNetworking(
                env: .sandbox,
                token: "dummy"
            ),
            paymentMethod: .mobilePay,
            returnURL: URL(string: "io.kronortest://")!,
            onPaymentFailure: {},
            onPaymentSuccess: {paymentId in }
        )
        WrapperView(header: CreditCardHeaderView(viewModel: viewModel)) {
            CreditCardWaitingView()
        }
    }
}
