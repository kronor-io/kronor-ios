//
//  ErroredStateRecoveryTests.swift
//

import XCTest
import KronorApi
@testable import KronorComponents

/// The errored state must not be a dead end: every statechart offers a retry
/// transition back to its initial state and a cancel path that notifies the
/// merchant app.
final class ErroredStateRecoveryTests: XCTestCase {

    private static let error = KronorApi.KronorError.networkError(error: URLError(.timedOut))

    // MARK: - Embedded

    func testEmbeddedErroredCanRetry() throws {
        let machine = EmbeddedPaymentStatechart.makeStateMachineWithInitialState(initial: .errored(error: Self.error))
        let result = try machine.transition(.retry)
        XCTAssertEqual(result.toState, .initializing)
        guard case .resetState = try XCTUnwrap(result.sideEffect) else {
            return XCTFail("retry must reset the flow state")
        }
    }

    func testEmbeddedErroredCanCancel() throws {
        let machine = EmbeddedPaymentStatechart.makeStateMachineWithInitialState(initial: .errored(error: Self.error))
        let result = try machine.transition(.cancelFlow)
        guard case .cancelAndNotifyError = try XCTUnwrap(result.sideEffect) else {
            return XCTFail("giving up after an error must report the failure, not a cancellation")
        }
    }

    // MARK: - Swish

    func testSwishErroredCanRetry() throws {
        let machine = SwishStatechart.makeStateMachineWithInitialState(initial: .errored(error: Self.error))
        let result = try machine.transition(.retry)
        XCTAssertEqual(result.toState, .promptingMethod)
        guard case .resetState = try XCTUnwrap(result.sideEffect) else {
            return XCTFail("retry must reset the flow state")
        }
    }

    func testSwishErroredCanCancel() throws {
        let machine = SwishStatechart.makeStateMachineWithInitialState(initial: .errored(error: Self.error))
        let result = try machine.transition(.cancelFlow)
        guard case .cancelAndNotifyError = try XCTUnwrap(result.sideEffect) else {
            return XCTFail("giving up after an error must report the failure, not a cancellation")
        }
    }

    // MARK: - Apple Pay

    func testApplePayErroredCanRetry() throws {
        let machine = ApplePayStatechart.makeStateMachineWithInitialState(initial: .errored(error: Self.error))
        let result = try machine.transition(.retry)
        XCTAssertEqual(result.toState, .initializing)
        guard case .resetState = try XCTUnwrap(result.sideEffect) else {
            return XCTFail("retry must reset the flow state")
        }
    }

    func testApplePayErroredCanCancel() throws {
        let machine = ApplePayStatechart.makeStateMachineWithInitialState(initial: .errored(error: Self.error))
        let result = try machine.transition(.cancelFlow)
        guard case .cancelAndNotifyError = try XCTUnwrap(result.sideEffect) else {
            return XCTFail("giving up after an error must report the failure, not a cancellation")
        }
    }
}
