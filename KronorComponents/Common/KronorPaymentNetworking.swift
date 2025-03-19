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

    init(
        env: Kronor.Environment,
        token: String,
        device: Kronor.Device?
    ) {
        self.env = env
        self.client = KronorApi.makeGraphQLClient(
            env: env,
            token: token
        )

        self.pollingManager = PollingManager(pollingInterval: 1)

        self.state = .init(device: device)
    }

    func establishWebSocketConnection() async throws -> NWConnection {
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

    func subscribeToPaymentStatus(
        resultHandler: @escaping (Result<KronorApi.PaymentStatusSubscription.Data, Error>, KronorApi.APIError?) -> Void
    ) async -> Cancellable {
        do {
            try await self.establishWebSocketConnection()
            return client.subscribe(
                subscription: KronorApi.PaymentStatusSubscription(),
                resultHandler: { result in
                    resultHandler(
                        result.flatMap({ graphQLData in
                            switch graphQLData.data {
                            case .some(let data):
                                return .success(data)
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
        } catch {
            return self.pollingManager.startPolling {
                self.client.fetch(query: KronorApi.PaymentStatusQuery(), cachePolicy: .fetchIgnoringCacheCompletely) { result in
                    resultHandler(
                        result.flatMap({ graphQLData in
                            switch graphQLData.data {
                            case .some(let data):
                                return .success(KronorApi.PaymentStatusSubscription.Data(_dataDict: data.__data))
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
