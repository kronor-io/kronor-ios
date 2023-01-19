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
    
    static func makeGraphQLClient(token: String) -> ApolloClient {
        let websocketsUrl = URL(string: "wss://staging.kronor.io/v1/graphql")!
        let webSocketClient = WebSocket(url: websocketsUrl, protocol: .graphql_ws)
        let payload: JSONEncodableDictionary = ["headers": ["Authorization": "Bearer " + token]]
        let wsConfig = WebSocketTransport.Configuration(reconnect:true, connectingPayload: payload)
        let webSocketTransport = WebSocketTransport(websocket: webSocketClient, store: store, config: wsConfig)
        
        let httpTransport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                     endpointURL: URL(string: "https://staging.kronor.io/v1/graphql")!,
                                                     additionalHeaders: ["Authorization": "Bearer " + token])
        let transport = SplitNetworkTransport(uploadingNetworkTransport: httpTransport, webSocketNetworkTransport: webSocketTransport)
        return ApolloClient(networkTransport: transport, store: store)
    }
    
    static func createSwishPaymentRequest(client: ApolloClient,
                                          input: KronorApi.SwishPaymentInput,
                                          deviceInfo: KronorApi.AddSessionDeviceInformationInput) async -> Result<String, KronorError> {
        await createPaymentRequest(client: client, mutation: KronorApi.SwishPaymentMutation(payment: input, deviceInfo: deviceInfo)) {
            $0.newSwishPayment.waitToken
        }
    }
    
    static func createMobilePayPaymentRequest(client: ApolloClient,
                                              input: KronorApi.MobilePayPaymentInput,
                                              deviceInfo: KronorApi.AddSessionDeviceInformationInput) async -> Result<String, KronorError> {
        await createPaymentRequest(client: client, mutation: KronorApi.MobilePayPaymentMutation(payment: input, deviceInfo: deviceInfo)) {
            $0.newMobilePayPayment.waitToken
        }
    }
}


func createPaymentRequest<Mutation: GraphQLMutation>(client: ApolloClient,
                                                     mutation: Mutation,
                                                     extractToken: @escaping (Mutation.Data) -> String) async -> Result<String, KronorApi.KronorError> {
    await withCheckedContinuation {continuation in
        client.perform(mutation: mutation) {data in
            switch data {
            case .failure(let error):
                continuation.resume(returning: .failure(.networkError(error: error)))
            case .success(let result):
                if let data = result.data {
                    continuation.resume(returning: .success(extractToken(data)))
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
