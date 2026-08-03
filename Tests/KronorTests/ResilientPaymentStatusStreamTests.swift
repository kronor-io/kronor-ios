//
//  ResilientPaymentStatusStreamTests.swift
//

import XCTest
import KronorApi
@testable import KronorComponents

final class ResilientPaymentStatusStreamTests: XCTestCase {

    private struct Transient: Error {}

    private static func success() -> PaymentStatusUpdate {
        (result: .success([]), apiError: nil)
    }

    private static func failure() -> PaymentStatusUpdate {
        (result: .failure(Transient()), apiError: nil)
    }

    /// Builds a stream factory that replays one scripted stream per
    /// subscription attempt, then blocks (like a healthy subscription).
    private final class ScriptedStreams: @unchecked Sendable {
        private var scripts: [[PaymentStatusUpdate]]
        private(set) var subscriptionCount = 0

        init(_ scripts: [[PaymentStatusUpdate]]) {
            self.scripts = scripts
        }

        func next() -> AsyncStream<PaymentStatusUpdate>? {
            guard !scripts.isEmpty else { return nil }
            subscriptionCount += 1
            let script = scripts.removeFirst()
            let keepOpen = scripts.isEmpty
            return AsyncStream { continuation in
                for update in script {
                    continuation.yield(update)
                }
                if !keepOpen {
                    continuation.finish()
                }
            }
        }
    }

    func testTransientFailuresAreSwallowedAndStreamIsReestablished() async {
        // First subscription fails and dies; the second one works. The
        // consumer must only ever see successful updates.
        let streams = ScriptedStreams([
            [Self.failure()],
            [Self.success(), Self.success()],
        ])

        let stream = resilientPaymentStatusStream(
            maxConsecutiveFailures: 5,
            resubscribeDelay: 0.01
        ) { streams.next() }

        var received: [PaymentStatusUpdate] = []
        for await update in stream {
            received.append(update)
            if received.count == 2 { break }
        }

        XCTAssertEqual(streams.subscriptionCount, 2, "a dead stream must be re-established")
        XCTAssertTrue(received.allSatisfy { update in
            if case .success = update.result { return true } else { return false }
        }, "transient failures must not reach the consumer")
    }

    func testSuccessResetsTheFailureBudget() async {
        let streams = ScriptedStreams([
            [Self.failure(), Self.failure(), Self.success(), Self.failure(), Self.failure(), Self.success()],
        ])

        let stream = resilientPaymentStatusStream(
            maxConsecutiveFailures: 3,
            resubscribeDelay: 0.01
        ) { streams.next() }

        var successes = 0
        for await update in stream {
            if case .success = update.result {
                successes += 1
                if successes == 2 { break }
            } else {
                XCTFail("no failure should surface: the budget resets after each success")
            }
        }
        XCTAssertEqual(successes, 2)
    }

    func testSustainedFailureSurfacesAnErrorAndFinishes() async {
        let streams = ScriptedStreams([
            [Self.failure(), Self.failure(), Self.failure(), Self.failure(), Self.failure()],
        ])

        let stream = resilientPaymentStatusStream(
            maxConsecutiveFailures: 3,
            resubscribeDelay: 0.01
        ) { streams.next() }

        var received: [PaymentStatusUpdate] = []
        for await update in stream {
            received.append(update)
        }

        XCTAssertEqual(received.count, 1, "exactly one failure surfaces once the budget is exhausted")
        guard case .failure = received[0].result else {
            return XCTFail("expected the surfaced update to be a failure")
        }
    }
}
