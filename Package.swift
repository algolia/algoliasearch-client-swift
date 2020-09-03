// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlgoliaSearchClient",
    platforms: [
<<<<<<< HEAD
        .iOS(.v9),
        .macOS(.v10_10),
=======
        .iOS(.v8),
        .macOS(.v10_15),
>>>>>>> Added SwiftCrypto as dependency for the linux target.
        .watchOS(.v2),
        .tvOS(.v9)
    ],
    products: [
        .library(
            name: "AlgoliaSearchClient",
            targets: ["AlgoliaSearchClient"])
    ],
    dependencies: [
<<<<<<< HEAD
        .package(url:"https://github.com/apple/swift-log.git", from: "1.4.0")
=======
        .package(url:"https://github.com/apple/swift-log.git", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "1.0.2")
>>>>>>> Added SwiftCrypto as dependency for the linux target.
    ],
    targets: [
        .target(
            name: "AlgoliaSearchClient",
            dependencies: ["Logging", "Crypto"]),
        .testTarget(
            name: "AlgoliaSearchClientTests",
            dependencies: ["AlgoliaSearchClient", "Logging", "Crypto"])
    ]
)
