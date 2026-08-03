//
//  StatusChannelResilienceTests.swift
//

import XCTest
@testable import Kronor
import KronorApi
@testable import KronorComponents

/// Emulated-outage tests against a local GraphQL server: the SDK's real
/// networking stack (Apollo HTTP + websocket) talks to ``LocalGraphQLServer``
/// on loopback while the tests inject the failures a backend failover or a
/// flaky network would produce — killed sockets, transient GraphQL errors —
/// and assert the shopper-visible behaviour.
final class StatusChannelResilienceTests: XCTestCase {

    private var server: LocalGraphQLServer!

    override func setUpWithError() throws {
        server = LocalGraphQLServer()
        try server.start()
    }

    override func tearDown() {
        server.stop()
        server = nil
    }

    // MARK: - Fixtures

    private static let waitToken = "e0f9b083-27e9-4a90-9dcf-08b46ecdff0a"

    private static func paymentRequestsPayload(status: String, resultingPaymentId: String? = nil) -> String {
        let paymentId = resultingPaymentId.map { #""\#($0)""# } ?? "null"
        return #"""
        {"data":{"paymentRequests":[{"__typename":"PaymentRequest","waitToken":"\#(waitToken)","amount":"1000","currency":"SEK","status":[{"__typename":"CurrentPaymentStatus","status":"\#(status)"}],"createdAt":"2026-01-01T00:00:00.000000+00:00","resultingPaymentId":\#(paymentId),"transactionSwishDetails":[{"__typename":"SwishDetails","errorCode":null,"returnUrl":"kronor-test://return","qrCode":"qr-data"}],"transactionCreditCardDetails":null,"transactionMobilePayDetails":null,"transactionVippsDetails":null,"transactionBankTransferDetails":null}]}}
        """#
    }

    private static let swishPaymentSuccessBody = #"""
        {"data":{"newSwishPayment":{"__typename":"SwishPaymentResult","waitToken":"\#(waitToken)"},"addSessionDeviceInformation":{"__typename":"AddSessionDeviceInformationResult","result":true}}}
        """#

    private static let temporaryFailureBody = #"""
        {"errors":[{"message":"database is briefly unavailable","extensions":{"type":"TEMPORARY_FAILURE"}}]}
        """#

    private func makeConfiguration(webSockets: Bool) -> ComponentConfiguration {
        let env = Kronor.Environment(
            name: "test",
            apiURL: URL(string: "http://127.0.0.1:\(server.httpPort)/v1/graphql")!,
            websocketURL: URL(string: "ws://127.0.0.1:\(server.wsPort)/v1/graphql")!,
            gatewayURL: URL(string: "http://127.0.0.1:\(server.httpPort)")!,
            cdeURL: URL(string: "http://127.0.0.1:\(server.httpPort)/cde/gql")!
        )
        return ComponentConfiguration(
            env: env,
            sessionToken: "test-token",
            returnURL: URL(string: "kronor-test://return")!,
            device: Kronor.Device(
                fingerprint: "test-fingerprint",
                appName: "KronorTests",
                appVersion: "1",
                deviceModel: "simulator",
                osName: "iOS",
                osVersion: "17"
            ),
            isWebSocketsEnabled: webSockets
        )
    }

    private static func waitUntil(
        timeout: TimeInterval,
        _ what: String,
        condition: @escaping @Sendable () async -> Bool
    ) async throws {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if await condition() { return }
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        struct TimedOut: Error {}
        XCTFail("timed out waiting for \(what)")
        throw TimedOut()
    }

    // MARK: - Tests

    /// Kills the websocket mid-subscription: the SDK must reconnect and
    /// resubscribe transparently, and the consumer must never see a failure.
    func testKilledWebSocketReconnectsAndKeepsDeliveringUpdates() async throws {
        let networking = KronorSwishPaymentNetworking(configuration: makeConfiguration(webSockets: true))

        actor Received {
            var successes = 0
            var failures = 0
            func record(_ update: PaymentStatusUpdate) {
                switch update.result {
                case .success: successes += 1
                case .failure: failures += 1
                }
            }
        }
        let received = Received()

        let stream = await networking.subscribeToPaymentStatus(onRetry: nil)
        let consumer = Task {
            for await update in stream {
                await received.record(update)
            }
        }
        defer { consumer.cancel() }

        try await Self.waitUntil(timeout: 10, "the initial subscription") { [server] in
            server!.hasActiveSubscription
        }
        let connectionsBeforeKill = server.wsConnectionCount

        server.pushSubscriptionData(Self.paymentRequestsPayload(status: "INITIALIZING"))
        try await Self.waitUntil(timeout: 5, "the first status update") {
            await received.successes >= 1
        }

        // The outage: every live socket dies abruptly.
        server.killWebSocketConnections()

        // Apollo must reconnect (3s interval) and resubscribe on its own.
        try await Self.waitUntil(timeout: 15, "the subscription to be re-established") { [server] in
            server!.wsConnectionCount > connectionsBeforeKill && server!.hasActiveSubscription
        }

        server.pushSubscriptionData(Self.paymentRequestsPayload(status: "PAID", resultingPaymentId: "12345"))
        try await Self.waitUntil(timeout: 5, "a status update after the reconnect") {
            await received.successes >= 2
        }

        let failures = await received.failures
        XCTAssertEqual(failures, 0, "a killed socket must never surface an error to the consumer")
    }

    /// Full Swish flow against the local server over polling, with transient
    /// failures on both the create mutation and the status channel: the
    /// shopper must end on the success screen and the merchant handler must
    /// receive the payment id.
    @MainActor
    func testSwishFlowSurvivesTransientFailuresEndToEnd() async throws {
        server.script(operation: "SwishPayment", responses: [
            (200, Self.temporaryFailureBody), // transient: retried with the same key
            (200, Self.swishPaymentSuccessBody),
        ])
        server.script(operation: "PaymentStatusQuery", responses: [
            (200, #"{"data":{"paymentRequests":[]}}"#),
            (503, ""),                        // transient poll failure: swallowed
            (200, Self.paymentRequestsPayload(status: "PAID", resultingPaymentId: "12345")),
        ])
        server.script(operation: "CancelSessionPayments", responses: [
            (200, #"{"data":{"cancelSessionPayments":{"__typename":"PaymentCancelResult","waitToken":null}}}"#),
        ])

        actor ResultBox {
            var result: PaymentResult?
            func set(_ r: PaymentResult) { result = r }
        }
        let resultBox = ResultBox()

        let viewModel = SwishPaymentViewModel(
            stateMachine: SwishStatechart.makeStateMachine(),
            networking: KronorSwishPaymentNetworking(configuration: makeConfiguration(webSockets: false)),
            returnURL: URL(string: "kronor-test://return")!,
            paymentResultHandler: { result in
                await resultBox.set(result)
            }
        )

        await viewModel.transition(.usePhoneNumber)
        await viewModel.transition(.phoneNumberInserted(number: "+46700000000"))

        try await Self.waitUntil(timeout: 20, "the flow to complete") { @MainActor in
            viewModel.state == .paymentCompleted
        }

        let result = await resultBox.result
        XCTAssertEqual(try XCTUnwrap(result).get(), "12345",
                       "the merchant handler must receive the resulting payment id")

        // The transient create failure must have been retried with the same
        // idempotency key: exactly two SwishPayment requests reached the wire.
        XCTAssertEqual(server.receivedOperations.filter { $0 == "SwishPayment" }.count, 2)
    }
}
