<p align="center">
  <a href="https://www.algolia.com">
    <img alt="Algolia for Swift" src="banner.png" >
  </a>
  
  <h4 align="center">The perfect starting point to integrate <a href="https://algolia.com" target="_blank">Algolia</a> within your Swift project</h4>

  <p align="center">
    <a href="https://cocoapods.org/pods/AlgoliaSearchClient">
      <img src="http://img.shields.io/cocoapods/v/AlgoliaSearchClient.svg?style=flat"></img>
    </a>
    <a href="https://cocoapods.org/pods/AlgoliaSearchClient">
      <img src="http://img.shields.io/cocoapods/p/AlgoliaSearchClient.svg?style=flat"></img>
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

### Swift Package Manager

The Swift Package Manager is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies. 
Since the release of Swift 5 and Xcode 11, SPM is compatible with the iOS, macOS and tvOS build systems for creating apps. 

To use SwiftPM, you should use Xcode 11 to open your project. Click `File` -> `Swift Packages` -> `Add Package Dependency`, enter [InstantSearch repo's URL](https://github.com/algolia/algoliasearch-client-swift).

If you're a framework author and use Algolia as a dependency, update your `Package.swift` file:

```swift
let package = Package(
    // 8.0.0 ..< 9.0.0
    dependencies: [
        .package(url: "https://github.com/algolia/algoliasearch-client-swift", from: "8.0.0")
    ],
    // ...
)
```

Add `import AlgoliaSearchClient` to your source files.

### Cocoapods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects.

To install Algolia Swift Client, simply add the following line to your Podfile:

```ruby
pod 'AlgoliaSearchClient', '~> 8.0'
# pod 'InstantSearchClient', '~> 6.0'` // Swift 4.2
# pod 'InstantSearchClient', '~> 5.0'` // Swift 4.1
```

Then, run the following command:

```bash
$ pod update
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a simple, decentralized dependency manager for Cocoa.

- To install InstantSearch, simply add the following line to your Cartfile:
```ruby
github "algolia/algoliasearch-client-swift" ~> 8.0.0
# github "algolia/algoliasearch-client-swift" ~> 6.0.0` // Swift 4.2
# github "algolia/algoliasearch-client-swift" ~> 5.0.0` // Swift 4.1
```

- Launch the following commands from the project directory
 ```shell
 carthage update
 ./Carthage/Checkouts/algoliasearch-client-swift/carthage-prebuild
 carthage build
 ```
 
If this is your first time using Carthage in the project, you'll need to go through some additional steps as explained [over at Carthage](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).


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

You can find code samples in the [Algolia's API Clients playground](https://github.com/algolia/api-clients-playground/tree/master/swift).

## 📄 License

Algolia Swift API Client is an open-sourced software licensed under the [MIT license](LICENSE.md).
