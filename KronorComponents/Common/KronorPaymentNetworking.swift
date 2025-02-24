//
//  KronorPaymentNetworking.swift
//  
//
//  Created by Niclas Heltoft on 17/07/2023.
//

import Foundation
import Apollo
import KronorApi
import Kronor

class KronorPaymentNetworking: PaymentNetworking {
    private actor State {
        var device: Kronor.Device?

        init(device: Kronor.Device?) {
            self.device = device
        }

        func setDevice(_ device: Kronor.Device?) {
            self.device = device
        }
    }

    private let state: State
    let client: ApolloClient
    var deviceInfo: KronorApi.AddSessionDeviceInformationInput {
        get async {
            if let device = await state.device {
                return device.deviceInfo
            }

            let device = await Kronor.detectDevice()
            await state.setDevice(device)
            return device.deviceInfo
        }
    }

    init(
        env: Kronor.Environment,
        token: String,
        device: Kronor.Device?
    ) {
        self.client = KronorApi.makeGraphQLClient(
            env: env,
            token: token
        )
        self.state = .init(device: device)
    }

    func subscribeToPaymentStatus(
        resultHandler: @escaping (Result<GraphQLResult<KronorApi.PaymentStatusSubscription.Data>, Error>) -> Void
    ) -> Cancellable {
        client.subscribe(
            subscription: KronorApi.PaymentStatusSubscription(),
            resultHandler: resultHandler
        )
    }

    func cancelSessionPayments() async -> Result<(), Never> {
        await withCheckedContinuation { continuation in
            client.perform(
                mutation: KronorApi.CancelSessionPaymentsMutation(
                    idempotencyKey: UUID().uuidString
                )
            ) { data in
                continuation.resume(
                    returning: .success(())
                )
            }
        }
    }
}
