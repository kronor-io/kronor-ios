//
//  Client.swift
//  kronor-ios
//

import Apollo
import ApolloAPI
import Foundation
import Kronor

public extension KronorCdeApi {
    struct APIError: Error {
        public var errors: [GraphQLError]
        public var extensions: JSONObject

        public init(errors: [GraphQLError], extensions: JSONObject) {
            self.errors = errors
            self.extensions = extensions
        }
    }

    enum CdeError: Error {
        case networkError(error: Error)
        case usageError(error: KronorCdeApi.APIError)
    }

    /// Creates a GraphQL client for the card data environment (CDE) API.
    /// - Parameters:
    ///   - env: The Kronor environment to use.
    ///   - token: The per-payment authorization token returned by `newApplePayPayment`.
    static func makeGraphQLClient(
        env: Kronor.Environment,
        token: String
    ) -> ApolloClient {
        let bearer = "Bearer " + token
        let store = ApolloStore(cache: InMemoryNormalizedCache())
        let httpTransport = RequestChainNetworkTransport(
            urlSession: URLSession(configuration: .default),
            interceptorProvider: DefaultInterceptorProvider.shared,
            store: store,
            endpointURL: env.cdeURL,
            additionalHeaders: ["Authorization": bearer]
        )

        return ApolloClient(networkTransport: httpTransport, store: store)
    }

    /// Submits an Apple Pay payment token for authorization.
    static func authorizeApplePayPayment(
        client: ApolloClient,
        token: KronorCdeApi.ApplePayPaymentTokenInput
    ) async -> Result<AuthorizeApplePayPaymentMutation.Data.AuthorizeApplePayPayment, CdeError> {
        let mutation = AuthorizeApplePayPaymentMutation(
            token: KronorCdeApi.AuthorizeApplePayPaymentInput(token: token)
        )
        do {
            let result = try await client.perform(mutation: mutation)
            return if let data = result.data {
                .success(data.authorizeApplePayPayment)
            } else {
                .failure(
                    .usageError(error: KronorCdeApi.APIError(
                        errors: result.errors ?? [], extensions: result.extensions ?? [:])
                    )
                )
            }
        } catch {
            return .failure(.networkError(error: error))
        }
    }
}
