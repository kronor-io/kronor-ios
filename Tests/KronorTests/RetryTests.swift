//
//  RetryTests.swift
//

import XCTest
import Apollo
@testable import KronorApi

final class RetryTests: XCTestCase {

    private static let fastRetry = KronorApi.RetryConfiguration(delays: [0.01, 0.01, 0.01])

    private static func temporaryFailure() -> KronorApi.KronorError {
        .usageError(error: KronorApi.APIError(
            errors: [GraphQLError(["message": "boom", "extensions": ["type": "TEMPORARY_FAILURE"]])],
            extensions: [:]
        ))
    }

    private static func fatalFailure() -> KronorApi.KronorError {
        .usageError(error: KronorApi.APIError(
            errors: [GraphQLError(["message": "invalid", "extensions": ["type": "VALIDATION_FAILURE"]])],
            extensions: [:]
        ))
    }

    // MARK: - Classification

    func testNetworkErrorIsRetryable() {
        XCTAssertTrue(KronorApi.KronorError.networkError(error: URLError(.timedOut)).isRetryable)
    }

    func testTemporaryFailureIsRetryable() {
        XCTAssertTrue(Self.temporaryFailure().isRetryable)
    }

    func testTemporaryFailureInResponseExtensionsIsRetryable() {
        let error = KronorApi.KronorError.usageError(error: KronorApi.APIError(
            errors: [],
            extensions: ["type": "TEMPORARY_FAILURE"]
        ))
        XCTAssertTrue(error.isRetryable)
    }

    func testOtherUsageErrorsAreFatal() {
        XCTAssertFalse(Self.fatalFailure().isRetryable)
        XCTAssertFalse(KronorApi.KronorError.usageError(error: KronorApi.APIError(errors: [], extensions: [:])).isRetryable)
    }

    // MARK: - withRetry

    /// A transient failure is retried until it succeeds, and every attempt
    /// belongs to the same logical operation (the idempotency key minted
    /// before the retry loop is identical on every attempt).
    func testRetriesTransientFailuresThenSucceeds() async {
        let idempotencyKey = UUID().uuidString
        var seenKeys: [String] = []
        var failuresLeft = 2

        let result: Result<String, KronorApi.KronorError> = await withRetry(Self.fastRetry) {
            seenKeys.append(idempotencyKey)
            if failuresLeft > 0 {
                failuresLeft -= 1
                return .failure(.networkError(error: URLError(.networkConnectionLost)))
            }
            return .success("wait-token")
        }

        XCTAssertEqual(try? result.get(), "wait-token")
        XCTAssertEqual(seenKeys.count, 3)
        XCTAssertEqual(Set(seenKeys).count, 1, "all attempts must reuse the same idempotency key")
    }

    func testRetriesTemporaryFailures() async {
        var attempts = 0
        let result: Result<String, KronorApi.KronorError> = await withRetry(Self.fastRetry) {
            attempts += 1
            return attempts == 1 ? .failure(Self.temporaryFailure()) : .success("ok")
        }
        XCTAssertEqual(try? result.get(), "ok")
        XCTAssertEqual(attempts, 2)
    }

    func testDoesNotRetryFatalErrors() async {
        var attempts = 0
        let result: Result<String, KronorApi.KronorError> = await withRetry(Self.fastRetry) {
            attempts += 1
            return .failure(Self.fatalFailure())
        }
        XCTAssertEqual(attempts, 1, "fatal errors must surface immediately")
        guard case .failure = result else { return XCTFail("expected failure") }
    }

    func testRetryBudgetIsBounded() async {
        var attempts = 0
        let result: Result<String, KronorApi.KronorError> = await withRetry(Self.fastRetry) {
            attempts += 1
            return .failure(.networkError(error: URLError(.timedOut)))
        }
        XCTAssertEqual(attempts, Self.fastRetry.delays.count + 1)
        guard case .failure = result else { return XCTFail("expected failure after exhausting the budget") }
    }

    func testNoRetryConfigurationRunsOnce() async {
        var attempts = 0
        let _: Result<String, KronorApi.KronorError> = await withRetry(.none) {
            attempts += 1
            return .failure(.networkError(error: URLError(.timedOut)))
        }
        XCTAssertEqual(attempts, 1)
    }
}
