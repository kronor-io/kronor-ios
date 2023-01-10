// @generated
// This file was automatically generated and should not be edited.
import Apollo
import ApolloWebSocket
import ApolloAPI
import Foundation

public enum KronorApi { }

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
}
