// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(Linux)
let macOSVersion: SupportedPlatform.MacOSVersion = .v10_15
#else
let macOSVersion: SupportedPlatform.MacOSVersion = .v11
#endif

#if os(Linux)
let extraPackageDependencies: [Package.Dependency] = [
  .package(url: "https://github.com/apple/swift-crypto.git", from: "1.1.2"),
  .package(url: "https://github.com/apple/swift-log.git", from: "1.5.4")
]
#else
let extraPackageDependencies: [Package.Dependency] = []
#endif

#if os(Linux)
let extraTargetDependencies: [Target.Dependency] = [
  .product(name: "Crypto", package: "swift-crypto"),
  .product(name: "Logging", package: "swift-log")
]
#else
let extraTargetDependencies: [Target.Dependency] = []
#endif

let package = Package(
  name: "AlgoliaSearchClient",
  platforms: [
    .iOS(.v14),
    .macOS(macOSVersion),
    .watchOS(.v7),
    .tvOS(.v14)
  ],
  products: [
    .library(
      name: "AlgoliaSearchClient",
      targets: ["AlgoliaSearchClient"])
  ],
  dependencies: [
  ] + extraPackageDependencies,
  targets: [
    .target(
      name: "AlgoliaSearchClient",
      dependencies: [
      ] + extraTargetDependencies),
    .testTarget(
      name: "AlgoliaSearchClientTests",
      dependencies: [
        .target(name: "AlgoliaSearchClient")
      ] + extraTargetDependencies)
  ]
)
