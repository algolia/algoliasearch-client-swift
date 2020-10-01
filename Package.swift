// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlgoliaSearchClient",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_10),
        .watchOS(.v2),
        .tvOS(.v9)
    ],
    products: [
        .library(
            name: "AlgoliaSearchClient",
            targets: ["AlgoliaSearchClient"])
    ],
    dependencies: [
        .package(url:"https://github.com/apple/swift-log.git", from: "1.4.0")
    ],
    targets: [
        .target(
            name: "AlgoliaSearchClient",
            dependencies: ["Logging"]),
        .testTarget(
            name: "AlgoliaSearchClientTests",
            dependencies: ["AlgoliaSearchClient", "Logging"])
    ]
)
