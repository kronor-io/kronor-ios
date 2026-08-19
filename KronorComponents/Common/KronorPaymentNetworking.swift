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
        onRetry: RetryNotification?,
        keepRetrying: KeepRetrying?
    ) async -> AsyncStream<PaymentStatusUpdate> {
        resilientPaymentStatusStream(onRetry: onRetry, keepRetrying: keepRetrying) { [weak self] in
            await self?.rawPaymentStatusStream()
        }
    }

    private func rawPaymentStatusStream() async -> AsyncStream<PaymentStatusUpdate> {
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

        // TLS only for wss:// endpoints, so that plain ws:// (local test
        // servers) can connect too.
        let isSecure = self.env.websocketURL.scheme?.lowercased() == "wss"
        let parameters = NWParameters(tls: isSecure ? NWProtocolTLS.Options() : nil, tcp: tcpOptions)
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

/// Signals that the payment status stream ended (e.g. the websocket closed)
/// and could not be re-established within the failure budget.
struct PaymentStatusStreamEnded: Error {}

/// Wraps a payment status stream so that transient failures don't reach the
/// consumer: failed updates are swallowed and the underlying stream is
/// re-created when it ends, with a delay between attempts. Only after
/// `maxConsecutiveFailures` failures in a row (with no successful update in
/// between) is a failure forwarded, after which the stream finishes. A
/// successful update resets the budget, so a long-lived subscription can
/// survive any number of isolated blips.
///
/// `keepRetrying` overrides that budget: while it answers `true` the failure is
/// never forwarded and the channel keeps trying indefinitely. The flow uses it
/// to hold the channel open for as long as the customer is on the payment site,
/// where giving up would mean abandoning a live payment.
func resilientPaymentStatusStream(
    maxConsecutiveFailures: Int = 5,
    resubscribeDelay: TimeInterval = 2,
    onRetry: RetryNotification? = nil,
    keepRetrying: KeepRetrying? = nil,
    makeStream: @escaping @Sendable () async -> AsyncStream<PaymentStatusUpdate>?
) -> AsyncStream<PaymentStatusUpdate> {
    AsyncStream { continuation in
        let task = Task {
            var consecutiveFailures = 0

            /// Returns true when the failure was fatal and the stream finished.
            func recordFailure(_ update: PaymentStatusUpdate) async -> Bool {
                consecutiveFailures += 1
                guard consecutiveFailures >= maxConsecutiveFailures else { return false }

                if await keepRetrying?() ?? false {
                    // Re-arm the budget and carry on: the consumer must not see
                    // this failure.
                    consecutiveFailures = 0
                    return false
                }

                continuation.yield(update)
                continuation.finish()
                return true
            }

            while !Task.isCancelled {
                guard let stream = await makeStream() else { break }

                for await update in stream {
                    if Task.isCancelled { break }

                    switch update.result {
                    case .success:
                        consecutiveFailures = 0
                        continuation.yield(update)
                    case .failure:
                        if await recordFailure(update) { return }
                        await onRetry?()
                    }
                }

                if Task.isCancelled { break }

                // The stream ended without being cancelled (e.g. dropped
                // websocket): count it against the budget and resubscribe.
                if await recordFailure((result: .failure(PaymentStatusStreamEnded()), apiError: nil)) { return }
                await onRetry?()

                try? await Task.sleep(nanoseconds: UInt64(resubscribeDelay * 1_000_000_000))
            }
            continuation.finish()
        }
        continuation.onTermination = { _ in
            task.cancel()
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
