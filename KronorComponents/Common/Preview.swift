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
    static let configuration: ComponentConfiguration = .init(
        env: env,
        sessionToken: token,
        returnURL: returnURL,
        device: device
    )
    static let env = Kronor.Environment.sandbox
    static let token = "dummy"
    static let returnURL = URL(string: "io.kronortest://")!
    static let device: Kronor.Device? = nil
    static let paymentResultHandler: PaymentResultHandler = { result in
        switch result {
        case .success(let paymentId):
            print("Payment successful: \(paymentId)")
        case .failure(let error):
            print("Payment failed: \(error)")
        }
    }

    @MainActor static func makeEmbeddedPaymentViewModel(
        paymentMethod: SupportedEmbeddedMethod,
        state: EmbeddedPaymentStatechart.State? = nil
    ) -> EmbeddedPaymentViewModel {
        let machine: EmbeddedPaymentStatechart.EmbeddedPaymentStateMachine
        if let state {
            machine = EmbeddedPaymentStatechart.makeStateMachineWithInitialState(initial: state)
        } else {
            machine = EmbeddedPaymentStatechart.makeStateMachine()
        }
        let networking = KronorEmbeddedPaymentNetworking(configuration: configuration)
        return EmbeddedPaymentViewModel(
            configuration: configuration,
            stateMachine: machine,
            networking: networking,
            paymentMethod: paymentMethod,
            paymentResultHandler: paymentResultHandler
        )
    }

    @MainActor static func makeSwishPaymentViewModel(
        state: SwishStatechart.State? = nil
    ) -> SwishPaymentViewModel {
        let machine: SwishStatechart.SwishStateMachine
        if let state {
            machine = SwishStatechart.makeStateMachineWithInitialState(initial: state)
        } else {
            machine = SwishStatechart.makeStateMachine()
        }
        let networking = KronorSwishPaymentNetworking(configuration: configuration)
        return SwishPaymentViewModel(
            stateMachine: machine,
            networking: networking,
            returnURL: returnURL,
            paymentResultHandler: paymentResultHandler
        )
    }
}
