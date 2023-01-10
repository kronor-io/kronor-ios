// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Kronor",
    platforms: [
      .iOS(.v12),
      .macOS(.v10_14),
      .tvOS(.v12),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Kronor",
            targets: ["Kronor"]),
        
        .library(
            name: "KronorApi",
            targets: ["KronorApi"]),
        
        
    ],
    dependencies: [
        .package(
            url: "https://github.com/apollographql/apollo-ios.git",
            from: "1.0.0"
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
            ],
            path: "./KronorApi"
        ),
        .target(
            name: "KronorComponents",
            dependencies: [
                .target(name: "KronorApi"),
                .product(name: "ApolloAPI", package: "apollo-ios"),
            ],
            path: "./KronorComponents"
        ),
        
    ]
)
