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
    let client: ApolloClient

    init(
        env: Kronor.Environment,
        token: String
    ) {
        self.client = KronorApi.makeGraphQLClient(
            env: env,
            token: token
        )
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
