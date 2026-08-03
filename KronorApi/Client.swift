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

        /// Whether the backend classified this error as transient
        /// (`extensions.type == "TEMPORARY_FAILURE"`), meaning the same
        /// request can be retried with the same idempotency key.
        public var isTemporaryFailure: Bool {
            let errorTypes = errors.compactMap { $0.extensions?["type"] as? String }
            let responseType = extensions["type"] as? String
            return errorTypes.contains("TEMPORARY_FAILURE") || responseType == "TEMPORARY_FAILURE"
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

        /// Transport failures and backend errors flagged as temporary can be
        /// retried with the same idempotency key; anything else is fatal.
        public var isRetryable: Bool {
            switch self {
            case .networkError:
                return true
            case .usageError(let error):
                return error.isTemporaryFailure
            }
        }
    }

    /// Bounded exponential backoff used when retrying payment mutations
    /// against transient failures.
    struct RetryConfiguration: Sendable {
        /// Delay before each retry; the number of entries bounds the retry budget.
        public var delays: [TimeInterval]

        public init(delays: [TimeInterval]) {
            self.delays = delays
        }

        /// Roughly 15s of retries, enough to span a short backend disruption.
        public static let `default` = RetryConfiguration(delays: [0.5, 1, 2, 4, 8])

        /// No retries: the first failure is returned as-is.
        public static let none = RetryConfiguration(delays: [])
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
            reconnectionInterval: 3,
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
        await sendMutation(client: client, mutation: KronorApi.ApplePayPaymentMutation(payment: input, deviceInfo: deviceInfo), retry: .default) {
            $0.newApplePayPayment
        }
    }

    static func createSwishPaymentRequest(client: ApolloClient,
                                          input: KronorApi.SwishPaymentInput,
                                          deviceInfo: KronorApi.AddSessionDeviceInformationInput) async -> Result<String, KronorError> {
        await sendMutation(client: client, mutation: KronorApi.SwishPaymentMutation(payment: input, deviceInfo: deviceInfo), retry: .default) {
            $0.newSwishPayment.waitToken
        }
    }
    
    static func createMobilePayPaymentRequest(client: ApolloClient,
                                              input: KronorApi.MobilePayPaymentInput,
                                              deviceInfo: KronorApi.AddSessionDeviceInformationInput) async -> Result<String, KronorError> {
        await sendMutation(client: client, mutation: KronorApi.MobilePayPaymentMutation(payment: input, deviceInfo: deviceInfo), retry: .default) {
            $0.newMobilePayPayment.waitToken
        }
    }
    
    static func createCreditCardPaymentRequest(client: ApolloClient,
                                               input: KronorApi.CreditCardPaymentInput,
                                               deviceInfo: KronorApi.AddSessionDeviceInformationInput) async -> Result<String, KronorError> {
        await sendMutation(client: client, mutation: KronorApi.CreditCardPaymentMutation(payment: input, deviceInfo: deviceInfo), retry: .default) {
            $0.newCreditCardPayment.waitToken
        }
    }
    
    static func createVippsPaymentRequest(client: ApolloClient,
                                          input: KronorApi.VippsPaymentInput,
                                          deviceInfo: KronorApi.AddSessionDeviceInformationInput) async -> Result<String, KronorError> {
        await sendMutation(client: client, mutation: KronorApi.VippsPaymentMutation(payment: input, deviceInfo: deviceInfo), retry: .default) {
            $0.newVippsPayment.waitToken
        }
    }
    
    static func createPayPalPaymentRequest(
        client: ApolloClient,
        input: KronorApi.PayPalPaymentInput,
        deviceInfo: KronorApi.AddSessionDeviceInformationInput) async -> Result<String, KronorError> {
            await sendMutation(client: client, mutation: KronorApi.PayPalPaymentMutation(payment: input, deviceInfo: deviceInfo), retry: .default) {
                $0.newPayPalPayment.paymentId
            }
    }

    static func createBankPaymentRequest(
        client: ApolloClient,
        input: KronorApi.BankTransferPaymentInput,
        deviceInfo: KronorApi.AddSessionDeviceInformationInput) async -> Result<String, KronorError> {
            await sendMutation(client: client, mutation: KronorApi.BankTransferPaymentMutation(payment: input, deviceInfo: deviceInfo), retry: .default) {
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
    retry: KronorApi.RetryConfiguration = .none,
    extractData: @escaping (Mutation.Data) -> OperationResult
) async -> Result<OperationResult, KronorApi.KronorError>
where Mutation.ResponseFormat == SingleResponseFormat {
    await withRetry(retry) {
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
}

/// Runs `operation`, retrying retryable failures after each delay in the
/// configuration. The retried operation must be idempotent: payment mutations
/// qualify because they carry an idempotency key that stays the same across
/// retries. Returns the first fatal failure, or the last failure once the
/// retry budget is exhausted. Stops early if the surrounding task is cancelled.
func withRetry<OperationResult>(
    _ configuration: KronorApi.RetryConfiguration,
    operation: () async -> Result<OperationResult, KronorApi.KronorError>
) async -> Result<OperationResult, KronorApi.KronorError> {
    var attempt = 0
    while true {
        let result = await operation()

        guard case .failure(let error) = result,
              error.isRetryable,
              attempt < configuration.delays.count,
              !Task.isCancelled
        else {
            return result
        }

        do {
            try await Task.sleep(nanoseconds: UInt64(configuration.delays[attempt] * 1_000_000_000))
        } catch {
            return result
        }
        attempt += 1
    }
}
