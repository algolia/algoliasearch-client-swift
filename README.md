<p align="center">
  <a href="https://www.algolia.com">
    <img alt="Algolia for Swift" src="https://raw.githubusercontent.com/algolia/algoliasearch-client-common/master/banners/swift.png" >
  </a>

<h4 align="center">The perfect starting point to integrate <a href="https://algolia.com" target="_blank">Algolia</a> within your Swift project</h4>

  <p align="center">
    <a href="https://github.com/algolia/algoliasearch-client-swift/actions/workflows/tests.yml">
      <img src="https://github.com/algolia/algoliasearch-client-swift/actions/workflows/tests.yml/badge.svg"></img>
    </a>
    <a href="https://cocoapods.org/pods/AlgoliaSearchClient">
      <img src="http://img.shields.io/cocoapods/v/AlgoliaSearchClient.svg?style=flat"></img>
    </a>
    <a href="https://cocoapods.org/pods/AlgoliaSearchClient">
      <img src="https://img.shields.io/badge/platform-macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux%20-lightgray.svg?style=flat"></img>
    </a>
    <a href="https://github.com/Carthage/Carthage">
      <img src="https://img.shields.io/badge/Carthage-compatible-brightgreen.svg"></img>
    </a>
    <a href="https://developer.apple.com/documentation/xcode/creating_a_mac_version_of_your_ipad_app/">
      <img src="https://img.shields.io/badge/Catalyst-compatible-brightgreen.svg"></img>
    </a>
    <a href="https://opensource.org/licenses/MIT">
      <img src="https://img.shields.io/badge/License-MIT-yellow.svg"></img>
    </a>
  </p>
</p>


<p align="center">
  <a href="https://www.algolia.com/doc/libraries/sdk/install#swift" target="_blank">Documentation</a>  •
  <a href="https://discourse.algolia.com" target="_blank">Community Forum</a>  •
  <a href="http://stackoverflow.com/questions/tagged/algolia" target="_blank">Stack Overflow</a>  •
  <a href="https://github.com/algolia/algoliasearch-client-swift/issues" target="_blank">Report a bug</a>  •
  <a href="https://alg.li/support" target="_blank">Support</a>
</p>

## ✨ Features

- Pure cross-platform Swift client
- Typed requests and responses
- Widespread use of `Result` type
- Uses the power of `Codable` protocol for easy integration of your domain models
- Thread-safe clients
- Detailed logging
- Injectable HTTP client

## 💡 Getting Started

### Swift Package Manager

The Swift Package Manager is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.
Since the release of Swift 5 and Xcode 11, SPM is compatible with the iOS, macOS and tvOS build systems for creating apps.

To use SwiftPM, you should use Xcode 11 to open your project. Click `File` -> `Swift Packages` -> `Add Package Dependency`, enter [the client repo's URL](https://github.com/algolia/algoliasearch-client-swift).

If you're a framework author and use Swift API Client as a dependency, update your `Package.swift` file:

```swift
let package = Package(
    // 9.0.0 ..< 10.0.0
    dependencies: [
        .package(url: "https://github.com/algolia/algoliasearch-client-swift", from: "9.0.0")
    ],
    // ...
)
```

### Cocoapods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects.

To install Algolia Swift Client, simply add the following line to your Podfile:

```ruby
pod 'AlgoliaSearchClient', '~> 9.0.0'
# pod 'InstantSearchClient', '~> 7.0' // Swift 5.9 NOT YET RELEASED
```

Then, run the following command:

```bash
$ pod update
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a simple, decentralized dependency manager for Cocoa.

- To install InstantSearch, simply add the following line to your Cartfile:
```ruby
github "algolia/algoliasearch-client-swift" ~> 9.0.0
```

- Launch the following commands from the project directory (for v.8.0+)
 ```shell
 carthage update
 ./Carthage/Checkouts/algoliasearch-client-swift/carthage-prebuild
 carthage build
 ```

If this is your first time using Carthage in the project, you'll need to go through some additional steps as explained [over at Carthage](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).

You can now import the Algolia API client in your project and play with it.

> Import the Core package and the required client package to your source code files:

```swift
#if canImport(Core)
    import Core
#endif
import Search

let client = try SearchClient(appID: "YOUR_APP_ID", apiKey: "YOUR_API_KEY")

// Add a new record to your Algolia index
let response = try await client.saveObject(
    indexName: "<YOUR_INDEX_NAME>",
    body: ["objectID": "id", "test": "val"]
)

// Poll the task status to know when it has been indexed
try await client.waitForTask(with: response.taskID, in: "<YOUR_INDEX_NAME>")

// Fetch search results, with typo tolerance
let response: SearchResponses<Hit> = try await client
    .search(searchMethodParams: SearchMethodParams(requests: [SearchQuery.searchForHits(SearchForHits(
        query: "<YOUR_QUERY>",
        hitsPerPage: 50,
        indexName: "<YOUR_INDEX_NAME>"
    ))]))
```

For full documentation, visit the **[Algolia Swift API Client](https://www.algolia.com/doc/libraries/sdk/install#swift)**.

## Notes

### Objective-C support

The Swift API client is compatible with Objective-C up to version 7.0.5. Please use this version of the client if you're working with an Objective-C project.

### Swift 3

You can use this library with Swift by one of the following ways:

- `pod 'AlgoliaSearch-Client-Swift', '~> 4.8.1'`
- `pod 'AlgoliaSearch-Client-Swift', :git => 'https://github.com/algolia/algoliasearch-client-swift.git', :branch => 'swift-3'`

### Swift 4

You can use the old library with Swift by one of the following ways:

- `pod 'AlgoliaSearch-Client-Swift', '~> 8.19'`
- `pod 'AlgoliaSearch-Client-Swift', :git => 'https://github.com/algolia/algoliasearch-client-swift.git', :branch => 'swift-4'`

## ❓ Troubleshooting

Encountering an issue? Before reaching out to support, we recommend heading to our [FAQ](https://support.algolia.com/hc/sections/15061037630609-API-Client-FAQs) where you will find answers for the most common issues and gotchas with the client. You can also open [a GitHub issue](https://github.com/algolia/api-clients-automation/issues/new?assignees=&labels=&projects=&template=Bug_report.md)

## Contributing

This repository hosts the code of the generated Algolia API client for Swift, if you'd like to contribute, head over to the [main repository](https://github.com/algolia/api-clients-automation). You can also find contributing guides on [our documentation website](https://api-clients-automation.netlify.app/docs/introduction).

## 📄 License

The Algolia Swift API Client is an open-sourced software licensed under the [MIT license](LICENSE).
