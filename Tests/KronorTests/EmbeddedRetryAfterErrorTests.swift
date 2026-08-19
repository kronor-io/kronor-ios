//
//  EmbeddedRetryAfterErrorTests.swift
//

import XCTest
@testable import Kronor
import KronorApi
@testable import KronorComponents

/// How the embedded flow behaves when the status channel fails: the channel is
/// driven over polling against ``LocalGraphQLServer`` and fed enough consecutive
/// errors to exhaust the resilient stream's budget. Where that lands depends on
/// whether the customer has been handed off to the payment site yet — before
/// handoff the error screen is offered, after it the site must stay up — and a
/// retry from the error screen must come all the way back.
final class EmbeddedRetryAfterErrorTests: XCTestCase {

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

    private static let firstWaitToken = "e0f9b083-27e9-4a90-9dcf-08b46ecdff0a"
    private static let secondWaitToken = "b7c1a2d4-1111-4e55-8a90-08b46ecdff0b"

    private static func paymentRequestsPayload(waitToken: String, status: String) -> String {
        #"""
        {"data":{"paymentRequests":[{"__typename":"PaymentRequest","waitToken":"\#(waitToken)","amount":"1000","currency":"SEK","status":[{"__typename":"CurrentPaymentStatus","status":"\#(status)"}],"createdAt":"2026-01-01T00:00:00.000000+00:00","resultingPaymentId":null,"transactionSwishDetails":null,"transactionCreditCardDetails":[{"__typename":"CreditCardDetails","sessionId":"sess","sessionUrl":"https://example.com/pay"}],"transactionMobilePayDetails":null,"transactionVippsDetails":null,"transactionBankTransferDetails":null}]}}
        """#
    }

    private static func creditCardSuccessBody(waitToken: String) -> String {
        #"""
        {"data":{"newCreditCardPayment":{"__typename":"CreditCardPaymentResult","waitToken":"\#(waitToken)"},"addSessionDeviceInformation":{"__typename":"AddSessionDeviceInformationResult","result":true}}}
        """#
    }

    private static let cancelSessionBody =
        #"{"data":{"cancelSessionPayments":{"__typename":"PaymentCancelResult","waitToken":null}}}"#

    private func makeConfiguration() -> ComponentConfiguration {
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
            // Polling rather than websockets, so that every status update is a
            // scriptable HTTP request and failures can be injected precisely.
            isWebSocketsEnabled: false
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

    private actor ResultBox {
        var results: [PaymentResult] = []
        func append(_ r: PaymentResult) { results.append(r) }
    }

    @MainActor
    private func makeViewModel(_ box: ResultBox) -> EmbeddedPaymentViewModel {
        EmbeddedPaymentViewModel(
            configuration: makeConfiguration(),
            stateMachine: EmbeddedPaymentStatechart.makeStateMachine(),
            networking: KronorEmbeddedPaymentNetworking(configuration: makeConfiguration()),
            paymentMethod: .creditCard,
            paymentResultHandler: { result in await box.append(result) }
        )
    }

    // MARK: - Tests

    /// The customer is on the payment site when the status channel starts
    /// failing. The site must stay up and the channel must keep re-establishing
    /// itself, because the payment is proceeding at the provider whether or not
    /// we can currently see it.
    @MainActor
    func testStatusChannelOutageDoesNotTearDownThePaymentSite() async throws {
        server.script(operation: "CreditCardPayment", responses: [
            (200, Self.creditCardSuccessBody(waitToken: Self.firstWaitToken)),
        ])
        server.script(operation: "PaymentStatusQuery", responses: [
            (200, Self.paymentRequestsPayload(waitToken: Self.firstWaitToken, status: "WAITING_FOR_PAYMENT")),
        ])
        server.script(operation: "CancelSessionPayments", responses: [(200, Self.cancelSessionBody)])

        let box = ResultBox()
        let viewModel = makeViewModel(box)

        await viewModel.transition(.initialize)

        try await Self.waitUntil(timeout: 20, "the payment site to open") { @MainActor in
            viewModel.embeddedSite != nil
        }
        let site = try XCTUnwrap(viewModel.embeddedSite)

        // The outage: every poll now fails, well past the failure budget of 5.
        server.script(operation: "PaymentStatusQuery", responses: [(503, "")])
        try await Task.sleep(nanoseconds: 15_000_000_000)

        XCTAssertEqual(
            viewModel.state.hashableIdentifier, .paymentRequestInitialized,
            "a status channel outage must not move the flow off the payment site"
        )
        XCTAssertEqual(
            viewModel.embeddedSite, site,
            "the payment site must stay up, and stay the same presentation, through the outage"
        )
        let results = await box.results
        XCTAssertTrue(results.isEmpty, "an outage must not report a result to the merchant app")

        // The channel must still be trying, not given up: it recovers on its own
        // once the backend does, with no customer interaction.
        server.script(operation: "PaymentStatusQuery", responses: [
            (200, Self.paymentRequestsPayload(waitToken: Self.firstWaitToken, status: "PAID")),
        ])
        try await Self.waitUntil(timeout: 30, "the flow to complete after the outage") { @MainActor in
            viewModel.state.hashableIdentifier == .paymentCompleted
        }

        XCTAssertFalse(
            server.receivedOperations.contains("CancelSessionPayments"),
            "an outage must never cancel the session's payments"
        )
    }

    /// Before handoff nothing is in flight, so failing to create the payment
    /// request is a safe place to offer a retry — and that retry must come all
    /// the way back and present the site, as a fresh presentation.
    @MainActor
    func testRetryAfterPreHandoffErrorReachesThePaymentSite() async throws {
        server.script(operation: "CreditCardPayment", responses: [(503, "")])
        server.script(operation: "PaymentStatusQuery", responses: [
            (200, #"{"data":{"paymentRequests":[]}}"#),
        ])
        server.script(operation: "CancelSessionPayments", responses: [(200, Self.cancelSessionBody)])

        let box = ResultBox()
        let viewModel = makeViewModel(box)

        await viewModel.transition(.initialize)

        try await Self.waitUntil(timeout: 30, "the flow to land on the error screen") { @MainActor in
            viewModel.state.hashableIdentifier == .errored
        }

        let resultsWhileErrored = await box.results
        XCTAssertTrue(resultsWhileErrored.isEmpty,
                      "entering the error state must not report a result to the merchant app")
        XCTAssertNil(viewModel.embeddedSite)

        // The backend recovers, and the customer taps "try again".
        server.script(operation: "CreditCardPayment", responses: [
            (200, Self.creditCardSuccessBody(waitToken: Self.secondWaitToken)),
        ])
        server.script(operation: "PaymentStatusQuery", responses: [
            (200, Self.paymentRequestsPayload(waitToken: Self.secondWaitToken, status: "WAITING_FOR_PAYMENT")),
        ])

        await viewModel.retry()

        try await Self.waitUntil(timeout: 30, "the payment site to be presented") { @MainActor in
            viewModel.embeddedSite != nil
        }

        XCTAssertEqual(viewModel.state.hashableIdentifier, .paymentRequestInitialized)
        XCTAssertFalse(
            server.receivedOperations.contains("CancelSessionPayments"),
            "retrying after an error must not cancel a payment we could not observe"
        )
        let resultsAfterRetry = await box.results
        XCTAssertTrue(resultsAfterRetry.isEmpty,
                      "a recovered retry must not report a failure to the merchant app")
    }

    /// Giving up on the error screen is what ends the flow, and it reports the
    /// failure the flow actually hit rather than a cancellation.
    @MainActor
    func testCancellingFromErroredReportsFailed() async throws {
        server.script(operation: "CreditCardPayment", responses: [(503, "")])
        server.script(operation: "PaymentStatusQuery", responses: [(503, "")])
        server.script(operation: "CancelSessionPayments", responses: [(200, Self.cancelSessionBody)])

        let box = ResultBox()
        let viewModel = makeViewModel(box)

        await viewModel.transition(.initialize)

        try await Self.waitUntil(timeout: 30, "the flow to land on the error screen") { @MainActor in
            viewModel.state.hashableIdentifier == .errored
        }
        let resultsBeforeGivingUp = await box.results
        XCTAssertTrue(resultsBeforeGivingUp.isEmpty)

        await viewModel.cancel()

        let results = await box.results
        XCTAssertEqual(results.count, 1, "the merchant app must be told exactly once")
        guard case .failure(.failed) = try XCTUnwrap(results.first) else {
            return XCTFail("giving up after an error must report .failed, not .cancelled")
        }
    }
}
