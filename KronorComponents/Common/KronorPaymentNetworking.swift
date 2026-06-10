//
//  KronorPaymentNetworking.swift
//
//
//  Created by Niclas Heltoft on 17/07/2023.
//

import Foundation
import Apollo
import ApolloWebSocket
import KronorApi
import Kronor
import Network

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
    private let webSocketTransport: WebSocketTransport?
    let pollingManager: PollingManager
    let env: Kronor.Environment
    let isWebSocketsEnabled: Bool

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

    init(configuration: ComponentConfiguration) {
        self.env = configuration.env
        let (client, webSocketTransport) = KronorApi.makeGraphQLClient(
            env: configuration.env,
            token: configuration.sessionToken
        )
        self.client = client
        self.webSocketTransport = webSocketTransport
        self.isWebSocketsEnabled = configuration.isWebSocketsEnabled
        self.pollingManager = PollingManager(pollingInterval: 1)
        self.state = .init(device: configuration.device)
    }

    deinit {
        let transport = webSocketTransport
        Task { await transport?.pause() }
    }

    func subscribeToPaymentStatus(
        resultHandler: @escaping (Result<[KronorApi.PaymentRequestFields], Error>, KronorApi.APIError?) -> Void
    ) async -> Task<Void, Never> {
        if isWebSocketsEnabled {
            do {
                return try await websocketPaymentStatusSubscription(resultHandler: resultHandler)
            } catch {
                return pollingPaymentStatusSubscription(resultHandler: resultHandler)
            }
        } else {
            return pollingPaymentStatusSubscription(resultHandler: resultHandler)
        }
    }

    func cancelSessionPayments() async -> Result<(), Never> {
        _ = try? await client.perform(
            mutation: KronorApi.CancelSessionPaymentsMutation(
                idempotencyKey: UUID().uuidString
            )
        )
        return .success(())
    }

    func refreshPaymentStatus() async -> Result<Bool, KronorApi.KronorError> {
        await KronorApi.refreshPaymentStatus(client: client)
    }
}

// MARK: - Helpers
extension KronorPaymentNetworking {
    private func establishWebSocketConnection() async throws -> NWConnection {
        let tcpOptions: NWProtocolTCP.Options = {
            let options = NWProtocolTCP.Options()
            options.connectionTimeout = 5
            return options
        }()

        let parameters = NWParameters(tls: NWProtocolTLS.Options(), tcp: tcpOptions)
        let websocketOptions = NWProtocolWebSocket.Options()
        websocketOptions.setSubprotocols(["graphql-ws"])

        parameters.defaultProtocolStack.applicationProtocols.insert(websocketOptions, at: 0)

        let connection = NWConnection(to: .url(self.env.websocketURL), using: parameters)

        return try await withCheckedThrowingContinuation { continuation in
            connection.stateUpdateHandler = { state in
                guard connection.stateUpdateHandler != nil else { return }

                switch state {
                case .ready:
                    connection.stateUpdateHandler = nil
                    continuation.resume(returning: connection)
                case .failed(let error):
                    connection.stateUpdateHandler = nil
                    continuation.resume(throwing: error)
                case .cancelled:
                    connection.stateUpdateHandler = nil
                    continuation.resume(throwing: CancellationError())
                case .waiting(let error):
                    connection.stateUpdateHandler = nil
                    continuation.resume(throwing: error)
                default:
                    break
                }
            }

            connection.start(queue: .main)
        }
    }

    private func websocketPaymentStatusSubscription(
        resultHandler: @escaping (Result<[KronorApi.PaymentRequestFields], Error>, KronorApi.APIError?) -> Void
    ) async throws -> Task<Void, Never> {
        _ = try await establishWebSocketConnection()
        let stream = try client.subscribe(subscription: KronorApi.PaymentStatusSubscription())
        return Task {
            do {
                for try await response in stream {
                    let apiError = response.extractAPIError()
                    if let data = response.data {
                        resultHandler(
                            .success(data.paymentRequests.map { $0.fragments.paymentRequestFields }),
                            apiError
                        )
                    } else {
                        resultHandler(
                            .failure(apiError ?? KronorApi.APIError.empty),
                            apiError
                        )
                    }
                }
            } catch {
                resultHandler(.failure(error), nil)
            }
        }
    }

    private func pollingPaymentStatusSubscription(
        resultHandler: @escaping (Result<[KronorApi.PaymentRequestFields], Error>, KronorApi.APIError?) -> Void
    ) -> Task<Void, Never> {
        pollingManager.startPolling {
            do {
                let response = try await self.client.fetch(
                    query: KronorApi.PaymentStatusQuery(),
                    cachePolicy: .networkOnly
                )
                let apiError = response.extractAPIError()
                if let data = response.data {
                    resultHandler(
                        .success(data.paymentRequests.map { $0.fragments.paymentRequestFields }),
                        apiError
                    )
                } else {
                    resultHandler(
                        .failure(apiError ?? KronorApi.APIError.empty),
                        apiError
                    )
                }
            } catch {
                resultHandler(.failure(error), nil)
            }
        }
    }
}

private extension GraphQLResponse {
    func extractAPIError() -> KronorApi.APIError? {
        let errors = self.errors ?? []
        let extensions = self.extensions ?? [:]
        guard !errors.isEmpty || !extensions.isEmpty else { return nil }
        return KronorApi.APIError(errors: errors, extensions: extensions)
    }
}
