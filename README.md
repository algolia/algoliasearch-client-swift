[![Pod Version](http://img.shields.io/cocoapods/v/AlgoliaSearchClientSwift.svg?style=flat)](http://cocoadocs.org/docsets/AlgoliaSearchClientSwift/)
[![Pod Platform](http://img.shields.io/cocoapods/p/AlgoliaSearchClientSwift.svg?style=flat)](http://cocoadocs.org/docsets/AlgoliaSearchClientSwift/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)](https://github.com/algolia/AlgoliaSearchClientSwift/)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Mac Catalyst compatible](https://img.shields.io/badge/Catalyst-compatible-brightgreen.svg)](https://developer.apple.com/documentation/xcode/creating_a_mac_version_of_your_ipad_app/)
[![Licence](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

<p align="center">
  <a href="https://www.algolia.com/doc/api-client/getting-started/install/swift/" target="_blank">Documentation</a>  •
  <a href="https://discourse.algolia.com" target="_blank">Community Forum</a>  •
  <a href="http://stackoverflow.com/questions/tagged/algolia" target="_blank">Stack Overflow</a>  •
  <a href="https://github.com/algolia/algoliasearch-client-swift/issues" target="_blank">Report a bug</a>  •
  <a href="https://www.algolia.com/support" target="_blank">Support</a>
</p>

## ✨ Features

- The Swift client is compatible with Swift `5.0.0` and higher.
- It is compatible with Kotlin project on the JVM, such as backend and Android applications.
- It relies on the open source Swift libraries for seamless integration into Swift projects:
  - [SwiftLog](https://github.com/apple/swift-log).
- The Swift client integrates the actual Algolia documentation in each source file: Request parameters, response fields, methods and concepts; all are documented and link to the corresponding url of the Algolia doc website.
- The client is thread-safe. You can use `Client`, `PlacesClient`, and `InsightsClient` in a multithreaded environment.

## Install

1. Add a dependency on InstantSearchClient:
    - CocoaPods: add `pod 'AlgoliaSearchClientSwift', '~> 8.0.0-beta.3'` to your `Podfile`.
    - Carthage: add `github "algolia/algoliasearch-client-swift" ~> 8.0.0-beta.3` to your `Cartfile`.
	- SwiftPM: add `.package(name: "AlgoliaSearchClientSwift", url: "https://github.com/algolia/algoliasearch-client-swift", from: "8.0.0-beta.3")` to your package dependencies array in `Package.swift`, then add `AlgoliaSearchClientSwift` to your target dependencies.
2. Add `import AlgoliaSearchClientSwift` to your source files.

## 💡 Getting Started


## 📄 License

Algolia Swift API Client is an open-sourced software licensed under the [MIT license](LICENSE.md).
