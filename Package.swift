// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Kronor",
    defaultLocalization: "en",
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
            name: "KronorCdeApi",
            targets: ["KronorCdeApi"]
        ),

        .library(
            name: "KronorComponents",
            targets: ["KronorComponents"]
        ),

    ],
    dependencies: [
        .package(
            url: "https://github.com/apollographql/apollo-ios.git",
            .upToNextMinor(from: "2.3.0")
        ),
        .package(
            url: "https://github.com/Tinder/StateMachine",
            .upToNextMajor(from: "0.3.0")
        ),
        .package(
            url: "https://github.com/trustly/TrustlyIosSdk",
            .upToNextMajor(from: "4.0.1")
        ),
    ],
    targets: [
        .target(
            name: "Kronor",
            path: "./Kronor"
        ),
        .target(
            name: "KronorApi",
            dependencies: [
                .target(name: "Kronor"),
                .product(name: "ApolloAPI", package: "apollo-ios"),
                .product(name: "ApolloWebSocket", package: "apollo-ios"),
            ],
            path: "./KronorApi"
        ),
        .target(
            name: "KronorCdeApi",
            dependencies: [
                .target(name: "Kronor"),
                .product(name: "ApolloAPI", package: "apollo-ios"),
                .product(name: "Apollo", package: "apollo-ios"),
            ],
            path: "./KronorCdeApi"
        ),
        .target(
            name: "KronorComponents",
            dependencies: [
                .target(name: "Kronor"),
                .target(name: "KronorApi"),
                .target(name: "KronorCdeApi"),
                .product(name: "Apollo", package: "apollo-ios"),
                .product(name: "StateMachine", package: "StateMachine"),
                .product(name: "TrustlyIosSdk", package: "TrustlyIosSdk")
            ],
            path: "./KronorComponents",
            resources: [
                .process("Assets"),
                .copy("PrivacyInfo.xcprivacy"),
            ]
        ),
        .testTarget(
            name: "KronorTests",
            dependencies: [
                .target(name: "Kronor"),
                .target(name: "KronorApi"),
                .target(name: "KronorComponents"),
            ],
            path: "./Tests/KronorTests"
        ),
    ]
)
