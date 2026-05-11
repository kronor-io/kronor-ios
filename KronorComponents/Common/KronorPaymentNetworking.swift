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
        self.client = KronorApi.makeGraphQLClient(
            env: configuration.env,
            token: configuration.sessionToken
        )
        self.isWebSocketsEnabled = configuration.isWebSocketsEnabled
        self.pollingManager = PollingManager(pollingInterval: 1)
        self.state = .init(device: configuration.device)
    }

    func subscribeToPaymentStatus(
        resultHandler: @escaping (Result<[KronorApi.PaymentRequestFields], Error>, KronorApi.APIError?) -> Void
    ) async -> Cancellable {
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
    ) async throws -> Cancellable {
        _ = try await establishWebSocketConnection()
        return client.subscribe(
            subscription: KronorApi.PaymentStatusSubscription(),
            resultHandler: { result in
                resultHandler(
                    result.flatMap({ graphQLData in
                        switch graphQLData.data {
                        case .some(let data):
                            return .success(data.paymentRequests.map { $0.fragments.paymentRequestFields })
                        case .none:
                            return .failure(
                                KronorApi.APIError(
                                    errors: [],
                                    extensions: [:]
                                )
                            )
                        }
                    }),
                    nil
                )
            }
        )
    }

    private func pollingPaymentStatusSubscription(
        resultHandler: @escaping (Result<[KronorApi.PaymentRequestFields], Error>, KronorApi.APIError?) -> Void
    ) -> Cancellable {
        pollingManager.startPolling {
            self.client.fetch(query: KronorApi.PaymentStatusQuery(), cachePolicy: .fetchIgnoringCacheCompletely) { result in
                resultHandler(
                    result.flatMap({ graphQLData in
                        switch graphQLData.data {
                        case .some(let data):
                            return .success(data.paymentRequests.map { $0.fragments.paymentRequestFields })
                        case .none:
                            return .failure(
                                KronorApi.APIError(
                                    errors: [],
                                    extensions: [:]
                                )
                            )
                        }
                    }),
                    KronorApi.APIError(
                        errors: (try? result.get().errors) ?? [],
                        extensions: (try? result.get().extensions) ?? [:]
                    )
                )
            }
        }
    }
}
