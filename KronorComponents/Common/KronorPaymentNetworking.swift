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

class KronorPaymentNetworking: PaymentNetworking, @unchecked Sendable {
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

    func subscribeToPaymentStatus() async -> AsyncStream<PaymentStatusUpdate> {
        if isWebSocketsEnabled {
            do {
                return try await websocketPaymentStatusStream()
            } catch {
                return pollingPaymentStatusStream()
            }
        } else {
            return pollingPaymentStatusStream()
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

    private func websocketPaymentStatusStream() async throws -> AsyncStream<PaymentStatusUpdate> {
        _ = try await establishWebSocketConnection()
        let subscriptionStream = try client.subscribe(subscription: KronorApi.PaymentStatusSubscription())
        return AsyncStream { continuation in
            let task = Task {
                do {
                    for try await response in subscriptionStream {
                        let apiError = response.extractAPIError()
                        if let data = response.data {
                            continuation.yield((
                                result: .success(data.paymentRequests.map { $0.fragments.paymentRequestFields }),
                                apiError: apiError
                            ))
                        } else {
                            continuation.yield((
                                result: .failure(apiError ?? .empty),
                                apiError: apiError
                            ))
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.yield((result: .failure(error), apiError: nil))
                    continuation.finish()
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    private func pollingPaymentStatusStream() -> AsyncStream<PaymentStatusUpdate> {
        AsyncStream { continuation in
            let task = pollingManager.startPolling { [client] in
                do {
                    let response = try await client.fetch(
                        query: KronorApi.PaymentStatusQuery(),
                        cachePolicy: .networkOnly
                    )
                    let apiError = response.extractAPIError()
                    if let data = response.data {
                        continuation.yield((
                            result: .success(data.paymentRequests.map { $0.fragments.paymentRequestFields }),
                            apiError: apiError
                        ))
                    } else {
                        continuation.yield((
                            result: .failure(apiError ?? .empty),
                            apiError: apiError
                        ))
                    }
                } catch {
                    continuation.yield((result: .failure(error), apiError: nil))
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
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
