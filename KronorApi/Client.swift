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

let store = ApolloStore(cache: InMemoryNormalizedCache())
let provider = DefaultInterceptorProvider(store: store)

public extension KronorApi {
    struct APIError: Error {
        public var errors : [GraphQLError]
        public var extensions : [String : AnyHashable]
        
        public init(errors: [GraphQLError], extensions: [String : AnyHashable]) {
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
    
    static func makeGraphQLClient(env: Kronor.Environment, token: String) -> ApolloClient {
        let websocketsUrl = Kronor.wsApiURL(env: env)
        let webSocketClient = WebSocket(url: websocketsUrl, protocol: .graphql_ws)
        let payload: JSONEncodableDictionary = ["headers": ["Authorization": "Bearer " + token]]
        let wsConfig = WebSocketTransport.Configuration(reconnect:true, connectingPayload: payload)
        let webSocketTransport = WebSocketTransport(websocket: webSocketClient, store: store, config: wsConfig)
        
        let httpTransport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                         endpointURL: Kronor.apiURL(env: env),
                                                         additionalHeaders: ["Authorization": "Bearer " + token])
        let transport = SplitNetworkTransport(uploadingNetworkTransport: httpTransport, webSocketNetworkTransport: webSocketTransport)
        return ApolloClient(networkTransport: transport, store: store)
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
    
    internal struct PayPalResult {
        let paymentData: Result<KronorApi.PayPalPaymentMutation.Data.NewPayPalPayment, KronorError>
        let braintreeSettings: Result<KronorApi.BraintreeSettingQuery.Data.BraintreeSetting, KronorError>
    }
    
    struct PayPalData {
        public var paymentData: KronorApi.PayPalPaymentMutation.Data.NewPayPalPayment
        public var braintreeSettings: KronorApi.BraintreeSettingQuery.Data.BraintreeSetting
    }
    
    static func createPayPalPaymentRequest(
        client: ApolloClient,
        input: KronorApi.PayPalPaymentInput,
        deviceInfo: KronorApi.AddSessionDeviceInformationInput) async -> Result<PayPalData, KronorError> {
            async let paymentData = sendMutation(client: client, mutation: KronorApi.PayPalPaymentMutation(payment: input, deviceInfo: deviceInfo)) {
                $0.newPayPalPayment
            }

            async let braintreeSettings = fetchBraintreeSettings(client: client)

            let result = await PayPalResult(
                paymentData: paymentData,
                braintreeSettings: braintreeSettings
            )

            return result.paymentData.flatMap { payment in
                result.braintreeSettings.map { settings in
                    PayPalData(
                        paymentData: payment,
                        braintreeSettings: settings
                    )
                }
            }
    }
    
    static func sendPayPalNonce(client: ApolloClient,
                                input: KronorApi.SupplyPayPalPaymentMethodIdInput) async -> Result<(), KronorError> {
        await sendMutation(client: client, mutation: KronorApi.SupplyPayPalPaymentMethodIdMutation(payment: input)) {_ in
            return ()
        }
    }
}


func sendMutation<Mutation: GraphQLMutation, OperationResult>(client: ApolloClient,
                                                     mutation: Mutation,
                                                     extractData: @escaping (Mutation.Data) -> OperationResult) async -> Result<OperationResult, KronorApi.KronorError> {
    await withCheckedContinuation {continuation in
        client.perform(mutation: mutation) {data in
            switch data {
            case .failure(let error):
                continuation.resume(returning: .failure(.networkError(error: error)))
            case .success(let result):
                if let data = result.data {
                    continuation.resume(returning: .success(extractData(data)))
                } else {
                    continuation.resume(returning: .failure(
                        .usageError(error: KronorApi.APIError(
                            errors: result.errors ?? [], extensions: result.extensions ?? [:])
                        ))
                    )
                }
            }
        }
    }
}

func fetchBraintreeSettings(client: ApolloClient) async -> Result<KronorApi.BraintreeSettingQuery.Data.BraintreeSetting, KronorApi.KronorError> {
    await withCheckedContinuation {continuation in
        client.fetch(query: KronorApi.BraintreeSettingQuery()) {data in
            switch data {
            case .failure(let error):
                continuation.resume(returning: .failure(.networkError(error: error)))
            case .success(let result):
                if let data = result.data {
                    continuation.resume(returning: .success(data.braintreeSetting[0]))
                } else {
                    continuation.resume(returning: .failure(
                        .usageError(error: KronorApi.APIError(
                            errors: result.errors ?? [], extensions: result.extensions ?? [:])
                        ))
                    )
                }
            }
        }
    }
}
