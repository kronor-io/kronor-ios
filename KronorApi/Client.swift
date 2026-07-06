//
//  Client.swift
//  
//
//  Created by lorenzo on 2023-01-13.
//

import Apollo
import ApolloWebSocket
import ApolloAPI
import Foundation
import Kronor

public extension KronorApi {
    struct APIError: Error {
        public var errors : [GraphQLError]
        public var extensions : JSONObject

        public init(errors: [GraphQLError], extensions: JSONObject) {
            self.errors = errors
            self.extensions = extensions
        }
    }
    
    enum KronorError: Error, Equatable {
        public static func == (lhs: KronorError, rhs: KronorError) -> Bool {
            switch (lhs, rhs) {
            case (.networkError(_), .networkError(_)):
                return true
            case (.usageError(_), .usageError(_)):
                return true
            default:
                return false
            }
        }
        
        case networkError (error: Error)
        case usageError (error: KronorApi.APIError)
    }
    
    static func makeGraphQLClient(
        env: Kronor.Environment,
        token: String
    ) -> (client: ApolloClient, webSocketTransport: WebSocketTransport?) {
        let bearer = "Bearer " + token
        let store = ApolloStore(cache: InMemoryNormalizedCache())
        let payload: JSONEncodableDictionary = ["headers": ["Authorization": bearer]]
        let httpTransport = RequestChainNetworkTransport(
            urlSession: URLSession(configuration: .default),
            interceptorProvider: DefaultInterceptorProvider.shared,
            store: store,
            endpointURL: env.apiURL,
            additionalHeaders: ["Authorization": bearer]
        )

        let wsConfig = WebSocketTransport.Configuration(
            reconnectionInterval: 0,
            connectingPayload: payload
        )
        if let webSocketTransport = try? WebSocketTransport(
            urlSession: URLSession(configuration: .default),
            store: store,
            endpointURL: env.websocketURL,
            configuration: wsConfig
        ) {
            let transport = SplitNetworkTransport(
                queryTransport: httpTransport,
                mutationTransport: httpTransport,
                subscriptionTransport: webSocketTransport
            )
            return (ApolloClient(networkTransport: transport, store: store), webSocketTransport)
        }

        return (ApolloClient(networkTransport: httpTransport, store: store), nil)
    }
    
    static func createApplePayPaymentRequest(client: ApolloClient,
                                             input: KronorApi.ApplePayPaymentInput,
                                             deviceInfo: KronorApi.AddSessionDeviceInformationInput) async -> Result<ApplePayPaymentMutation.Data.NewApplePayPayment, KronorError> {
        await sendMutation(client: client, mutation: KronorApi.ApplePayPaymentMutation(payment: input, deviceInfo: deviceInfo)) {
            $0.newApplePayPayment
        }
    }

    static func createSwishPaymentRequest(client: ApolloClient,
                                          input: KronorApi.SwishPaymentInput,
                                          deviceInfo: KronorApi.AddSessionDeviceInformationInput) async -> Result<String, KronorError> {
        await sendMutation(client: client, mutation: KronorApi.SwishPaymentMutation(payment: input, deviceInfo: deviceInfo)) {
            $0.newSwishPayment.waitToken
        }
    }
    
    static func createMobilePayPaymentRequest(client: ApolloClient,
                                              input: KronorApi.MobilePayPaymentInput,
                                              deviceInfo: KronorApi.AddSessionDeviceInformationInput) async -> Result<String, KronorError> {
        await sendMutation(client: client, mutation: KronorApi.MobilePayPaymentMutation(payment: input, deviceInfo: deviceInfo)) {
            $0.newMobilePayPayment.waitToken
        }
    }
    
    static func createCreditCardPaymentRequest(client: ApolloClient,
                                               input: KronorApi.CreditCardPaymentInput,
                                               deviceInfo: KronorApi.AddSessionDeviceInformationInput) async -> Result<String, KronorError> {
        await sendMutation(client: client, mutation: KronorApi.CreditCardPaymentMutation(payment: input, deviceInfo: deviceInfo)) {
            $0.newCreditCardPayment.waitToken
        }
    }
    
    static func createVippsPaymentRequest(client: ApolloClient,
                                          input: KronorApi.VippsPaymentInput,
                                          deviceInfo: KronorApi.AddSessionDeviceInformationInput) async -> Result<String, KronorError> {
        await sendMutation(client: client, mutation: KronorApi.VippsPaymentMutation(payment: input, deviceInfo: deviceInfo)) {
            $0.newVippsPayment.waitToken
        }
    }
    
    static func createPayPalPaymentRequest(
        client: ApolloClient,
        input: KronorApi.PayPalPaymentInput,
        deviceInfo: KronorApi.AddSessionDeviceInformationInput) async -> Result<String, KronorError> {
            await sendMutation(client: client, mutation: KronorApi.PayPalPaymentMutation(payment: input, deviceInfo: deviceInfo)) {
                $0.newPayPalPayment.paymentId
            }
    }

    static func createBankPaymentRequest(
        client: ApolloClient,
        input: KronorApi.BankTransferPaymentInput,
        deviceInfo: KronorApi.AddSessionDeviceInformationInput) async -> Result<String, KronorError> {
            await sendMutation(client: client, mutation: KronorApi.BankTransferPaymentMutation(payment: input, deviceInfo: deviceInfo)) {
                $0.newBankTransferPayment.paymentId
            }
    }

    static func refreshPaymentStatus(client: ApolloClient) async -> Result<Bool, KronorError> {
        await sendMutation(client: client, mutation: KronorApi.RefreshPaymentStatusMutation()) {
            $0.refreshPaymentStatus.result
        }
    }
}


func sendMutation<Mutation: GraphQLMutation, OperationResult>(
    client: ApolloClient,
    mutation: Mutation,
    extractData: @escaping (Mutation.Data) -> OperationResult
) async -> Result<OperationResult, KronorApi.KronorError>
where Mutation.ResponseFormat == SingleResponseFormat {
    do {
        let result = try await client.perform(mutation: mutation)
        return if let data = result.data {
            .success(extractData(data))
        } else {
            .failure(
                .usageError(error: KronorApi.APIError(
                    errors: result.errors ?? [], extensions: result.extensions ?? [:])
                )
            )
        }
    } catch {
        return .failure(.networkError(error: error))
    }
}
