// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(Linux)
let macOSVersion: SupportedPlatform.MacOSVersion = .v10_15
#else
let macOSVersion: SupportedPlatform.MacOSVersion = .v10_10
#endif

#if os(Linux)
let extraPackageDependencies: [Package.Dependency] = [
  .package(url: "https://github.com/apple/swift-crypto.git", from: "1.1.2")
]
#else
let extraPackageDependencies: [Package.Dependency] = []
#endif

#if os(Linux)
let extraTargetDependencies: [Target.Dependency] = [
  .product(name: "Crypto", package: "swift-crypto")
]
#else
let extraTargetDependencies: [Target.Dependency] = []
#endif

let package = Package(
  name: "AlgoliaSearchClient",
  platforms: [
    .iOS(.v9),
    .macOS(macOSVersion),
    .watchOS(.v2),
    .tvOS(.v9)
  ],
  products: [
    .library(
      name: "AlgoliaSearchClient",
      targets: ["AlgoliaSearchClient"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-log.git", from: "1.5.3")
  ] + extraPackageDependencies,
  targets: [
    .target(
      name: "AlgoliaSearchClient",
      dependencies: [
        .product(name: "Logging", package: "swift-log")
      ] + extraTargetDependencies),
    .testTarget(
      name: "AlgoliaSearchClientTests",
      dependencies: [
        .target(name: "AlgoliaSearchClient"),
        .product(name: "Logging", package: "swift-log")
      ] + extraTargetDependencies)
  ]
)
