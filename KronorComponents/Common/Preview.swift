//
//  Preview.swift
//  
//
//  Created by Niclas Heltoft on 21/07/2023.
//

import Foundation
import Kronor
import KronorApi

enum Preview {
    static let env = Kronor.Environment.sandbox
    static let token = "dummy"
    static let returnURL = URL(string: "io.kronortest://")!

    static func makeEmbeddedPaymentViewModel(
        paymentMethod: SupportedEmbeddedMethod,
        state: EmbeddedPaymentStatechart.State? = nil
    ) -> EmbeddedPaymentViewModel {
        let machine: EmbeddedPaymentStatechart.EmbeddedPaymentStateMachine
        if let state {
            machine = EmbeddedPaymentStatechart.makeStateMachineWithInitialState(initial: state)
        } else {
            machine = EmbeddedPaymentStatechart.makeStateMachine()
        }
        let networking = KronorEmbeddedPaymentNetworking(
            env: env,
            token: token
        )
        return EmbeddedPaymentViewModel(
            env: env,
            sessionToken: token,
            stateMachine: machine,
            networking: networking,
            paymentMethod: paymentMethod,
            returnURL: returnURL,
            onPaymentFailure: { reason in },
            onPaymentSuccess: { paymentId in }
        )
    }

    static func makeSwishPaymentViewModel(
        state: SwishStatechart.State? = nil
    ) -> SwishPaymentViewModel {
        let machine: SwishStatechart.SwishStateMachine
        if let state {
            machine = SwishStatechart.makeStateMachineWithInitialState(initial: state)
        } else {
            machine = SwishStatechart.makeStateMachine()
        }
        let networking = KronorSwishPaymentNetworking(
            env: env,
            token: token
        )
        return SwishPaymentViewModel(
            stateMachine: machine,
            networking: networking,
            returnURL: returnURL,
            onPaymentFailure: { reason in },
            onPaymentSuccess: { paymentId in }
        )
    }
}
