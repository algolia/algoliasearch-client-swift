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

- The Swift client is compatible with Swift 5 and higher.
- It relies on the open source Swift libraries for seamless integration into Swift projects:
  - [SwiftLog](https://github.com/apple/swift-log).
- Asynchronous and synchronous methods to interact with Algolia's API
- Thread-safe clients
- Typed requests and responses
- Injectable HTTP client

## Install

1. Add a dependency on InstantSearchClient:
    - CocoaPods
    	add `pod 'AlgoliaSearchClientSwift', '~> 8.0.0-beta.3'` to your `Podfile`.
    - Carthage 
      - add `github "algolia/algoliasearch-client-swift" ~> 8.0.0-beta.3` to your `Cartfile`.
      - launch the following commands from the project directory
		   ```shell
		   carthage update
		   cd Carthage/Checkouts/algoliasearch-client-swift
		   swift package generate-xcodeproj
		   cd ../swift-log
		   swift package generate-xcodeproj
		   cd ../../..
		   carthage build
		   ```
    - Swift Package Manager
      - add `.package(name: "AlgoliaSearchClientSwift", url: "https://github.com/algolia/algoliasearch-client-swift", from: "8.0.0-beta.3")` to your package dependencies array in `Package.swift`
      - add `AlgoliaSearchClientSwift` to your target dependencies.
2. Add `import AlgoliaSearchClientSwift` to your source files.

## 💡 Getting Started

### Initialize the client

To start, you need to initialize the client. To do this, you need your **Application ID** and **API Key**.
You can find both on [your Algolia account](https://www.algolia.com/api-keys).

```swift
let client = Client(appID: "YourApplicationID", apiKey: "YourAdminAPIKey")
let index = client.index(withName: "your_index_name")
```

### Push data

Without any prior configuration, you can start indexing contacts in the `contacts` index using the following code:

```swift
struct Contact {
  let firstname:  String
  let lastname: String
  let followersCount: Int
  let company: String
  let objectID: String
}

let index = client.index(withName: "contacts")

let contact = Contact(firstname: "Jimmie", 
		      lastname: "Barninger", 
		      followersCount: 93, 
		      company: "California Paint", 
		      objectID: "one")

try index.saveObject(contact)
```

### Search

You can now search for contacts by `firstname`, `lastname`, `company`, etc. (even with typos):

```swift
// Synchronous search
let searchResponse = try index.search(query: "jimmie")

// Asynchronous search
index.search(query: "jimmie") { result in
  switch result {
  case .failure(let error):
    ...
  case .success(let searchResponse):
    ...
  }
}

```

For full documentation, visit the [Algolia Swift API Client's documentation](https://www.algolia.com/doc/api-client/getting-started/install/swift/).

## 📝 Examples

You can find code samples in the [Algolia's API Clients playground](https://github.com/algolia/api-clients-playground/tree/master/java/src/main/swift).

## 📄 License

Algolia Swift API Client is an open-sourced software licensed under the [MIT license](LICENSE.md).
