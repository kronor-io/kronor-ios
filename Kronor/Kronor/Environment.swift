//
//  Environment.swift
//  
//
//  Created by lorenzo on 2023-01-19.
//

import Foundation

public extension Kronor {
    struct Environment {
        public let name: String
        public let apiURL: URL
        public let websocketURL: URL
        public let gatewayURL: URL
    }
}

public extension Kronor.Environment {
    static let production = Kronor.Environment(
        name: "prod",
        apiURL: URL(string: "https://kronor.io/v1/graphql")!,
        websocketURL: URL(string: "wss://kronor.io/v1/graphql")!,
        gatewayURL: URL(string: "https://payment-gateway.kronor.io")!
    )

    static let sandbox = Kronor.Environment(
        name: "staging",
        apiURL: URL(string: "https://staging.kronor.io/v1/graphql")!,
        websocketURL: URL(string: "wss://staging.kronor.io/v1/graphql")!,
        gatewayURL: URL(string: "https://payment-gateway.staging.kronor.io")!
    )
}
