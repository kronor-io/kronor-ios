//
//  EmbeddedRetryAfterErrorTests.swift
//

import XCTest
@testable import Kronor
import KronorApi
@testable import KronorComponents

/// How the embedded flow recovers from the error screen: the status channel is
/// driven over polling against ``LocalGraphQLServer`` and fed enough consecutive
/// errors to exhaust the resilient stream's budget, which lands the flow on the
/// error screen. From there the customer can retry, which must come all the way
/// back and present the embedded site again, or give up.
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

    /// The site goes up, the backend starts failing every poll, the flow lands on
    /// the error screen, the backend recovers, and the customer taps retry. The
    /// site must be presented again — as a *new* presentation, since the session
    /// URL is unchanged and re-presenting the old one would reuse a dead webview.
    @MainActor
    func testRetryAfterErroredRepresentsTheEmbeddedSite() async throws {
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

        try await Self.waitUntil(timeout: 20, "the embedded site to open") { @MainActor in
            viewModel.embeddedSite != nil
        }
        let firstSite = try XCTUnwrap(viewModel.embeddedSite)

        // The outage: every poll now fails, which exhausts the resilient
        // stream's budget and lands the flow on the error screen.
        server.script(operation: "PaymentStatusQuery", responses: [(503, "")])

        try await Self.waitUntil(timeout: 30, "the flow to land on the error screen") { @MainActor in
            viewModel.state.hashableIdentifier == .errored
        }

        // The customer can still retry, so the merchant app must not have been
        // handed a result yet.
        let resultsWhileErrored = await box.results
        XCTAssertTrue(resultsWhileErrored.isEmpty,
                      "entering the error state must not report a result to the merchant app")
        XCTAssertNil(viewModel.embeddedSite,
                     "the failed attempt's site must be taken down with the error screen")

        // The backend recovers, and the customer taps "try again".
        server.script(operation: "CreditCardPayment", responses: [
            (200, Self.creditCardSuccessBody(waitToken: Self.secondWaitToken)),
        ])
        server.script(operation: "PaymentStatusQuery", responses: [
            (200, Self.paymentRequestsPayload(waitToken: Self.secondWaitToken, status: "WAITING_FOR_PAYMENT")),
        ])

        await viewModel.retry()

        try await Self.waitUntil(timeout: 30, "the embedded site to be presented again") { @MainActor in
            viewModel.embeddedSite != nil
        }
        let secondSite = try XCTUnwrap(viewModel.embeddedSite)

        XCTAssertEqual(viewModel.state.hashableIdentifier, .paymentRequestInitialized)
        XCTAssertNotEqual(
            secondSite.id, firstSite.id,
            "the retried attempt needs a fresh identity, otherwise SwiftUI reuses the dead webview"
        )
        XCTAssertEqual(secondSite.url, firstSite.url, "the session URL itself does not change")
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
