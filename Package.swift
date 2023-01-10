// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Kronor",
    platforms: [
      .iOS(.v15),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Kronor",
            targets: ["Kronor"]
        ),
        
        .library(
            name: "KronorApi",
            targets: ["KronorApi"]
        ),
        
        .library(
            name: "KronorComponents",
            targets: ["KronorComponents"]
        ),

    ],
    dependencies: [
        .package(
            url: "https://github.com/apollographql/apollo-ios.git",
            .upToNextMajor(from: "1.0.0")
        ),
        .package(
            url: "https://github.com/Tinder/StateMachine",
            .upToNextMajor(from: "0.3.0")
        ),
    ],
    targets: [
        .target(
            name: "Kronor",
            dependencies: [],
            path: "./Kronor"
        ),
        .target(
            name: "KronorApi",
            dependencies: [
                .product(name: "ApolloAPI", package: "apollo-ios"),
                .product(name: "ApolloWebSocket", package: "apollo-ios"),
            ],
            path: "./KronorApi"
        ),
        .target(
            name: "KronorComponents",
            dependencies: [
                .target(name: "KronorApi"),
                .product(name: "Apollo", package: "apollo-ios"),
                .product(name: "StateMachine", package: "StateMachine"),
            ],
            path: "./KronorComponents" 
        ),
        
    ]
)
