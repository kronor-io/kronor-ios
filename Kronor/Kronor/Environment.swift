//
//  Environment.swift
//  
//
//  Created by lorenzo on 2023-01-19.
//

import Foundation

let productionURL = URL(string: "https://kronor.io/v1/graphql")!
let sandboxURL = URL(string: "https://staging.kronor.io/v1/graphql")!

let productionWsURL = URL(string: "wss://kronor.io/v1/graphql")!
let sandboxWsURL = URL(string: "wss://staging.kronor.io/v1/graphql")!


let productionGatewayURL = URL(string: "https://payment-gateway.kronor.io")!
let sandboxGatewayURL = URL(string: "https://payment-gateway.staging.kronor.io")!

public extension Kronor {
    enum Environment {
        case production
        case sandbox
    }

    static func apiURL(env: Environment) -> URL {
        switch env {
        case .production:
            return productionURL
        case .sandbox:
            return sandboxURL
        }
    }
    
    static func wsApiURL(env: Environment) -> URL {
        switch env {
        case .production:
            return productionWsURL
        case .sandbox:
            return sandboxWsURL
        }
    }

    static func gatewayURL(env: Environment) -> URL {
        switch env {
        case .production:
            return productionGatewayURL
        case .sandbox:
            return sandboxGatewayURL
        }
    }
}
