//
//  LocalGraphQLServer.swift
//

import Foundation
import Network
import XCTest

/// An in-process stand-in for the Kronor GraphQL backend, listening on
/// loopback. It serves scripted HTTP responses (keyed by GraphQL operation
/// name) and speaks enough graphql-transport-ws to drive Apollo's websocket
/// subscriptions — with fault-injection hooks (killing live sockets, failing
/// requests) so tests can emulate outages and connection drops.
final class LocalGraphQLServer: @unchecked Sendable {

    private let lock = NSRecursiveLock()

    private var httpListener: NWListener!
    private var wsListener: NWListener!
    private(set) var httpPort: UInt16 = 0
    private(set) var wsPort: UInt16 = 0

    private var wsConnections: [NWConnection] = []
    private var httpConnections: [NWConnection] = []

    /// Scripted HTTP response bodies per GraphQL operation name. Each request
    /// consumes the first entry; the last entry is sticky (repeated polls).
    private var httpScripts: [String: [(status: Int, body: String)]] = [:]

    /// The subscription ids of currently active graphql-transport-ws
    /// subscriptions, per connection.
    private var activeSubscriptions: [(connection: NWConnection, id: String)] = []

    /// Total websocket connections ever accepted (to assert reconnections).
    private(set) var wsConnectionCount = 0

    /// All GraphQL operation names received over HTTP, in order.
    private(set) var receivedOperations: [String] = []

    // MARK: - Lifecycle

    func start() throws {
        httpListener = try Self.makeListener(webSocket: false)
        wsListener = try Self.makeListener(webSocket: true)

        httpListener.newConnectionHandler = { [weak self] connection in
            self?.acceptHTTP(connection)
        }
        wsListener.newConnectionHandler = { [weak self] connection in
            self?.acceptWebSocket(connection)
        }

        let queue = DispatchQueue(label: "LocalGraphQLServer")
        httpListener.start(queue: queue)
        wsListener.start(queue: queue)

        httpPort = try Self.waitForPort(of: httpListener)
        wsPort = try Self.waitForPort(of: wsListener)
    }

    func stop() {
        lock.lock(); defer { lock.unlock() }
        httpListener?.cancel()
        wsListener?.cancel()
        (wsConnections + httpConnections).forEach { $0.cancel() }
        wsConnections = []
        httpConnections = []
        activeSubscriptions = []
    }

    private static func makeListener(webSocket: Bool) throws -> NWListener {
        let parameters = NWParameters.tcp
        if webSocket {
            let options = NWProtocolWebSocket.Options()
            options.autoReplyPing = true
            options.setSubprotocols(["graphql-transport-ws", "graphql-ws"])
            parameters.defaultProtocolStack.applicationProtocols.insert(options, at: 0)
        }
        return try NWListener(using: parameters, on: .any)
    }

    private static func waitForPort(of listener: NWListener) throws -> UInt16 {
        let deadline = Date().addingTimeInterval(5)
        while Date() < deadline {
            if let port = listener.port?.rawValue, port > 0 { return port }
            Thread.sleep(forTimeInterval: 0.01)
        }
        throw XCTSkip("could not bind a loopback listener")
    }

    // MARK: - Scripting & fault injection

    func script(operation: String, responses: [(status: Int, body: String)]) {
        lock.lock(); defer { lock.unlock() }
        httpScripts[operation] = responses
    }

    /// Abruptly closes every live websocket connection, like a network drop
    /// or a backend failover would.
    func killWebSocketConnections() {
        lock.lock(); defer { lock.unlock() }
        wsConnections.forEach { $0.forceCancel() }
        wsConnections = []
        activeSubscriptions = []
    }

    /// Sends a `next` payload to every active subscription.
    func pushSubscriptionData(_ payload: String) {
        lock.lock(); defer { lock.unlock() }
        for (connection, id) in activeSubscriptions {
            let message = #"{"id":"\#(id)","type":"next","payload":\#(payload)}"#
            sendText(message, over: connection)
        }
    }

    var hasActiveSubscription: Bool {
        lock.lock(); defer { lock.unlock() }
        return !activeSubscriptions.isEmpty
    }

    // MARK: - HTTP handling

    private func acceptHTTP(_ connection: NWConnection) {
        lock.lock()
        httpConnections.append(connection)
        lock.unlock()
        connection.start(queue: DispatchQueue(label: "http-conn"))
        receiveHTTPRequest(connection, buffer: Data())
    }

    private func receiveHTTPRequest(_ connection: NWConnection, buffer: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            guard let self, error == nil, let data else { return }
            var buffer = buffer
            buffer.append(data)

            if let request = Self.parseHTTPRequest(buffer) {
                self.respondHTTP(connection, requestBody: request)
            } else if !isComplete {
                self.receiveHTTPRequest(connection, buffer: buffer)
            }
        }
    }

    /// Returns the request body once fully buffered, nil while incomplete.
    private static func parseHTTPRequest(_ raw: Data) -> Data? {
        guard let headerEnd = raw.range(of: Data("\r\n\r\n".utf8)) else { return nil }
        let headers = String(decoding: raw[..<headerEnd.lowerBound], as: UTF8.self)
        let contentLength = headers
            .split(separator: "\r\n")
            .first { $0.lowercased().hasPrefix("content-length:") }
            .flatMap { Int($0.split(separator: ":")[1].trimmingCharacters(in: .whitespaces)) }
            ?? 0
        let body = raw[headerEnd.upperBound...]
        return body.count >= contentLength ? Data(body.prefix(contentLength)) : nil
    }

    private func respondHTTP(_ connection: NWConnection, requestBody: Data) {
        let operation = (try? JSONSerialization.jsonObject(with: requestBody) as? [String: Any])
            .flatMap { $0?["operationName"] as? String }
            ?? "unknown"

        lock.lock()
        receivedOperations.append(operation)
        var response = (status: 200, body: #"{"errors":[{"message":"unscripted operation \#(operation)"}]}"#)
        if var queue = httpScripts[operation], !queue.isEmpty {
            response = queue.count == 1 ? queue[0] : queue.removeFirst()
            httpScripts[operation] = queue
        }
        lock.unlock()

        let body = Data(response.body.utf8)
        var head = "HTTP/1.1 \(response.status) \(response.status == 200 ? "OK" : "Error")\r\n"
        head += "Content-Type: application/json\r\n"
        head += "Content-Length: \(body.count)\r\n"
        head += "Connection: close\r\n\r\n"

        connection.send(content: Data(head.utf8) + body, completion: .contentProcessed { _ in
            connection.cancel()
        })
    }

    // MARK: - WebSocket handling (graphql-transport-ws)

    private func acceptWebSocket(_ connection: NWConnection) {
        lock.lock()
        wsConnections.append(connection)
        wsConnectionCount += 1
        lock.unlock()
        connection.start(queue: DispatchQueue(label: "ws-conn"))
        receiveWebSocketMessage(connection)
    }

    private func receiveWebSocketMessage(_ connection: NWConnection) {
        connection.receiveMessage { [weak self] data, context, _, error in
            guard let self, error == nil else { return }
            if let data, !data.isEmpty,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let type = json["type"] as? String {
                switch type {
                case "connection_init":
                    self.sendText(#"{"type":"connection_ack"}"#, over: connection)
                case "subscribe", "start":
                    if let id = json["id"] as? String {
                        self.lock.lock()
                        self.activeSubscriptions.append((connection, id))
                        self.lock.unlock()
                    }
                case "complete", "stop":
                    self.lock.lock()
                    self.activeSubscriptions.removeAll { $0.connection === connection && $0.id == (json["id"] as? String) }
                    self.lock.unlock()
                default:
                    break
                }
            }
            self.receiveWebSocketMessage(connection)
        }
    }

    private func sendText(_ text: String, over connection: NWConnection) {
        let metadata = NWProtocolWebSocket.Metadata(opcode: .text)
        let context = NWConnection.ContentContext(identifier: "text", metadata: [metadata])
        connection.send(
            content: Data(text.utf8),
            contentContext: context,
            isComplete: true,
            completion: .contentProcessed { _ in }
        )
    }
}
