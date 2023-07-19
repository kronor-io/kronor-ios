//
//  CreditCardHeaderView.swift
//
//
//  Created by lorenzo on 2023-01-18.
//


import SwiftUI
import KronorApi
import Kronor

struct CreditCardHeaderView: View {
    @ObservedObject var viewModel: EmbeddedPaymentViewModel

    var body: some View {
        VStack {
            HStack() {
                Spacer()
                VStack {
                    Image(systemName:
                            [.errored, .paymentRejected].contains(viewModel.state.hashableIdentifier) ? "creditcard.trianglebadge.exclamationmark" : "creditcard")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }.frame(width: 150,
                        height: 250,
                        alignment: .leading)
                Spacer()
            }
        }.frame(width: 350,
                height: 350,
                alignment: .leading)
    }
}

struct CreditCardHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        let machine = EmbeddedPaymentStatechart.makeStateMachine()
        let env = Kronor.Environment.sandbox
        let token = "dummy"
        let networking = KronorEmbeddedPaymentNetworking(
            env: env,
            token: token
        )
        let viewModel = EmbeddedPaymentViewModel(
            env: env,
            sessionToken: token,
            stateMachine: machine,
            networking: networking,
            paymentMethod: .mobilePay,
            returnURL: URL(string: "io.kronortest://")!,
            onPaymentFailure: {},
            onPaymentSuccess: {paymentId in }
        )

        WrapperView(header: CreditCardHeaderView(viewModel: viewModel)) {
            Text("Dummy contents")
        }
        .previewDisplayName("Header")
        
        let machine2 = EmbeddedPaymentStatechart.makeStateMachineWithInitialState(
            initial: .errored(error: .usageError(error: KronorApi.APIError(errors: [], extensions: [:])))
        )
        let viewModel2 = EmbeddedPaymentViewModel(
            env: env,
            sessionToken: token,
            stateMachine: machine2,
            networking: networking,
            paymentMethod: .mobilePay,
            returnURL: URL(string: "io.kronortest://")!,
            onPaymentFailure: {},
            onPaymentSuccess: {paymentId in }
        )
        
        WrapperView(header: CreditCardHeaderView(viewModel: viewModel2)) {
            Text("Dummy contents")
        }
        .previewDisplayName("Header Error")
    }
}
