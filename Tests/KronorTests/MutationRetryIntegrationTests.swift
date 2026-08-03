//
//  MutationRetryIntegrationTests.swift
//

import XCTest
import Apollo
import ApolloAPI
@testable import KronorApi

/// End-to-end validation of the mutation retry behaviour through a real
/// `ApolloClient`: a stubbed `URLProtocol` scripts the HTTP responses, so
/// these tests exercise the full request chain — request serialization, the
/// retry loop, and classification of real GraphQL error payloads — and
/// assert at the wire level that every attempt of a logical payment carries
/// the same idempotency key.
final class MutationRetryIntegrationTests: XCTestCase {

    // MARK: - Stub transport

    /// Scripted HTTP responses, one per request, shared with `StubURLProtocol`.
    final class Script: @unchecked Sendable {
        static let shared = Script()
        private let lock = NSLock()
        private var responses: [(status: Int, body: String)] = []
        private var requests: [Data] = []

        func reset(responses: [(status: Int, body: String)]) {
            lock.lock(); defer { lock.unlock() }
            self.responses = responses
            self.requests = []
        }

        func nextResponse(recording body: Data) -> (status: Int, body: String) {
            lock.lock(); defer { lock.unlock() }
            requests.append(body)
            return responses.isEmpty ? (500, "") : responses.removeFirst()
        }

        var recordedBodies: [Data] {
            lock.lock(); defer { lock.unlock() }
            return requests
        }
    }

    final class StubURLProtocol: URLProtocol {
        override class func canInit(with request: URLRequest) -> Bool { true }
        override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

        override func startLoading() {
            let body = request.httpBody
                ?? request.httpBodyStream.map { stream in
                    stream.open()
                    defer { stream.close() }
                    var data = Data()
                    let bufferSize = 4096
                    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
                    defer { buffer.deallocate() }
                    while stream.hasBytesAvailable {
                        let read = stream.read(buffer, maxLength: bufferSize)
                        if read <= 0 { break }
                        data.append(buffer, count: read)
                    }
                    return data
                }
                ?? Data()

            let (status, responseBody) = Script.shared.nextResponse(recording: body)
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: status,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: responseBody.data(using: .utf8)!)
            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}
    }

    private static func makeStubbedClient() -> ApolloClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        let store = ApolloStore(cache: InMemoryNormalizedCache())
        let transport = RequestChainNetworkTransport(
            urlSession: URLSession(configuration: configuration),
            interceptorProvider: DefaultInterceptorProvider.shared,
            store: store,
            endpointURL: URL(string: "https://stub.invalid/v1/graphql")!
        )
        return ApolloClient(networkTransport: transport, store: store)
    }

    // MARK: - Fixtures

    private static let temporaryFailureBody = """
        {"errors":[{"message":"database is briefly unavailable","extensions":{"type":"TEMPORARY_FAILURE","code":"unexpected"}}]}
        """

    private static let validationFailureBody = """
        {"errors":[{"message":"invalid phone number","extensions":{"type":"VALIDATION_FAILURE","code":"validation-failed"}}]}
        """

    private static let successBody = """
        {"data":{"newSwishPayment":{"__typename":"SwishPaymentResult","waitToken":"token-1"},"addSessionDeviceInformation":{"__typename":"AddSessionDeviceInformationResult","result":true}}}
        """

    private static let deviceInfo = KronorApi.AddSessionDeviceInformationInput(
        browserName: "test",
        browserVersion: "1",
        fingerprint: "test-fingerprint",
        osName: "iOS",
        osVersion: "17",
        userAgent: "test"
    )

    private static func createPayment() async -> Result<String, KronorApi.KronorError> {
        let input = KronorApi.SwishPaymentInput(
            customerSwishNumber: .some("+46700000000"),
            flow: "ecom",
            idempotencyKey: UUID().uuidString,
            returnUrl: "kronor://return"
        )
        return await KronorApi.createSwishPaymentRequest(
            client: makeStubbedClient(),
            input: input,
            deviceInfo: deviceInfo
        )
    }

    private static func idempotencyKeys(in bodies: [Data]) throws -> [String] {
        try bodies.map { body in
            let json = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
            let variables = try XCTUnwrap(json["variables"] as? [String: Any])
            let payment = try XCTUnwrap(variables["payment"] as? [String: Any])
            return try XCTUnwrap(payment["idempotencyKey"] as? String)
        }
    }

    // MARK: - Tests

    func testPaymentIsRetriedThroughTheRealClientWithAStableKey() async throws {
        // Two transient failures — one at the GraphQL layer, one at the HTTP
        // layer — then success. All of it must be transparent to the caller.
        Script.shared.reset(responses: [
            (200, Self.temporaryFailureBody),
            (503, ""),
            (200, Self.successBody),
        ])

        let result = await Self.createPayment()

        XCTAssertEqual(try result.get(), "token-1")

        let keys = try Self.idempotencyKeys(in: Script.shared.recordedBodies)
        XCTAssertEqual(keys.count, 3, "expected the two failures to be retried")
        XCTAssertEqual(Set(keys).count, 1, "every retry must reuse the same idempotency key")
    }

    func testFatalErrorsAreNotRetriedThroughTheRealClient() async throws {
        Script.shared.reset(responses: [
            (200, Self.validationFailureBody),
            (200, Self.successBody), // must never be reached
        ])

        let result = await Self.createPayment()

        guard case .failure(.usageError(let apiError)) = result else {
            return XCTFail("expected the validation failure to surface, got \(result)")
        }
        XCTAssertFalse(apiError.isTemporaryFailure)
        XCTAssertEqual(Script.shared.recordedBodies.count, 1, "fatal errors must not be retried")
    }

    func testTemporaryFailureBeyondTheBudgetSurfacesAsRetryable() async throws {
        // More transient failures than the retry budget allows: the error
        // must surface (so the flow can land in the recoverable error state).
        Script.shared.reset(responses: Array(
            repeating: (200, Self.temporaryFailureBody),
            count: KronorApi.RetryConfiguration.default.delays.count + 1
        ))

        let result = await Self.createPayment()

        guard case .failure(let error) = result else {
            return XCTFail("expected failure once the budget is exhausted")
        }
        XCTAssertTrue(error.isRetryable)

        let keys = try Self.idempotencyKeys(in: Script.shared.recordedBodies)
        XCTAssertEqual(keys.count, KronorApi.RetryConfiguration.default.delays.count + 1)
        XCTAssertEqual(Set(keys).count, 1)
    }
}
