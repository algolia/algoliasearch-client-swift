// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlgoliaSearchClientSwift",
    platforms: [
        .iOS(.v8),
        .macOS(.v10_12),
        .watchOS(.v2),
        .tvOS(.v9)
    ],
    products: [
        .library(
            name: "AlgoliaSearchClientSwift",
            targets: ["AlgoliaSearchClientSwift"])
    ],
    dependencies: [
        .package(url:"https://github.com/apple/swift-log.git", from: "1.2.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "AlgoliaSearchClientSwift",
            dependencies: ["Logging"]),
        .testTarget(
            name: "AlgoliaSearchClientSwiftTests",
            dependencies: ["AlgoliaSearchClientSwift", "Logging"])
    ]
)
