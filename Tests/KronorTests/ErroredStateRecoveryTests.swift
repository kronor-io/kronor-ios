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
        guard case .resetStateWithoutCancelling = try XCTUnwrap(result.sideEffect) else {
            return XCTFail("retrying after an error must not cancel a payment we cannot see")
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
        guard case .resetStateWithoutCancelling = try XCTUnwrap(result.sideEffect) else {
            return XCTFail("retrying after an error must not cancel a payment we cannot see")
        }
    }

    func testSwishErroredCanCancel() throws {
        let machine = SwishStatechart.makeStateMachineWithInitialState(initial: .errored(error: Self.error))
        let result = try machine.transition(.cancelFlow)
        guard case .cancelAndNotifyError = try XCTUnwrap(result.sideEffect) else {
            return XCTFail("giving up after an error must report the failure, not a cancellation")
        }
    }

    // MARK: - No error exit while on a payment surface

    /// Once the customer is on the payment site, a status channel failure must
    /// not be able to move the flow to the error screen: the payment may already
    /// have been made, and the error screen offers a retry that would ask for a
    /// second one.
    func testEmbeddedPostHandoffStatesHaveNoErrorExit() throws {
        for state: EmbeddedPaymentStatechart.State in [.paymentRequestInitialized, .waitingForPayment] {
            let machine = EmbeddedPaymentStatechart.makeStateMachineWithInitialState(initial: state)
            XCTAssertThrowsError(
                try machine.transition(.error(error: Self.error)),
                "\(state) must not have an error exit while the payment site is up"
            )
        }
    }

    /// Before handoff nothing is in flight, so erroring out is correct there.
    func testEmbeddedPreHandoffStatesKeepTheirErrorExit() throws {
        let machine = EmbeddedPaymentStatechart.makeStateMachineWithInitialState(initial: .creatingPaymentRequest)
        XCTAssertEqual(
            try machine.transition(.error(error: Self.error)).toState.hashableIdentifier, .errored
        )
    }

    // MARK: - Apple Pay

    func testApplePayErroredCanRetry() throws {
        let machine = ApplePayStatechart.makeStateMachineWithInitialState(initial: .errored(error: Self.error))
        let result = try machine.transition(.retry)
        XCTAssertEqual(result.toState, .initializing)
        guard case .resetStateWithoutCancelling = try XCTUnwrap(result.sideEffect) else {
            return XCTFail("retrying after an error must not cancel a payment we cannot see")
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
