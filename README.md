[![Build Status](https://www.bitrise.io/app/6dcd3d9dd961c466/status.svg?token=q1GX8YovgWTvPx7Ueu77JQ)](https://www.bitrise.io/app/6dcd3d9dd961c466)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![SwiftPM Compatible](https://img.shields.io/badge/SwiftPM-Compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![CocoaPods](https://img.shields.io/cocoapods/v/AlgoliaSearch-Client-Swift.svg)]()
[![CocoaPods](https://img.shields.io/cocoapods/l/AlgoliaSearch-Client-Swift.svg)]()
[![](https://img.shields.io/badge/OS%20X-10.9%2B-lightgrey.svg)]()
[![](https://img.shields.io/badge/iOS-7.0%2B-lightgrey.svg)]()
[![Swift 4.0](https://img.shields.io/badge/Swift-4.0-orange.svg)]()
<a href="https://developer.apple.com/documentation/objectivec"><img src="https://img.shields.io/badge/Objective--C-compatible-blue.svg" alt="Objective-C compatible" /></a>

# Algolia Search API Client for Swift and Objective-C

[Algolia Search](https://www.algolia.com) is a hosted full-text, numerical, and faceted search engine capable of delivering realtime results from the first keystroke.
The **Algolia Search API Client** lets you easily use the [Algolia Search REST API](https://www.algolia.com/doc/rest-api/search) from your Swift code.

**That being said, the library is 100% compatible with Objective-C**

As a complement to this readme, you can browse the automatically generated [reference documentation](https://community.algolia.com/algoliasearch-client-swift/).
(See also the [offline-enabled version](https://community.algolia.com/algoliasearch-client-swift/offline/).)

## API Documentation

You can find the full reference on the [Algolia's website](https://www.algolia.com/doc/api-client/swift/).


## Table of Contents


1. **[Supported platforms](#supported-platforms)**


1. **[Install](#install)**


1. **[Quick Start](#quick-start)**

    * [Initialize the client](#initialize-the-client)
    * [Push data](#push-data)
    * [Search](#search)
    * [Configure](#configure)

1. **[Getting Help](#getting-help)**





# Getting Started



## Supported platforms

Our Swift client is supported on **iOS**, **macOS**, **tvOS** and **watchOS**,
and is usable from both **Swift** and **Objective-C**.

## Install

1. Add a dependency on AlgoliaSearch-Client-Swift:
    - CocoaPods: add `pod 'AlgoliaSearch-Client-Swift', '~> 5.0'` to your `Podfile`.
    - Carthage: add `github "algolia/algoliasearch-client-swift"` to your `Cartfile`.
	- SwiftPM: add `.package(url:"https://github.com/algolia/algoliasearch-client-swift", from: "5.0.0")` to your package dependencies array in `Package.swift`, then add `AlgoliaSearch` to your target dependencies.
2. Add `import AlgoliaSearch` to your source files.

## Quick Start

In 30 seconds, this quick start tutorial will show you how to index and search objects.

### Initialize the client

You first need to initialize the client. For that you need your **Application ID** and **API Key**.
You can find both of them on [your Algolia account](https://www.algolia.com/api-keys).

```swift
let client = Client(appID: "YourApplicationID", apiKey: "YourAPIKey")
```

### Push data

Without any prior configuration, you can start indexing [500 contacts](https://github.com/algolia/algoliasearch-client-csharp/blob/master/contacts.json) in the ```contacts``` index using the following code:

```swift
// Load content file
let jsonURL = Bundle.main.url(forResource: "contacts", withExtension: "json")
let jsonData = try! Data(contentsOf: jsonURL!)
let dict = try! JSONSerialization.jsonObject(with: jsonData!)

// Load all objects in the JSON file into an index named "contacts".
let index = client.index(withName: "contacts")
index.addObjects(dict["objects"])
```

### Search

You can now search for contacts using firstname, lastname, company, etc. (even with typos):

```swift
// search by firstname
index.search(Query(query: "jimmie"), completionHandler: { (content, error) -> Void in
	if error == nil {
		print("Result: \(content)")
	}
})
// search a firstname with typo
index.search(Query(query: "jimie"), completionHandler: { (content, error) -> Void in
	if error == nil {
		print("Result: \(content)")
	}
})
// search for a company
index.search(Query(query: "california paint"), completionHandler: { (content, error) -> Void in
	if error == nil {
		print("Result: \(content)")
	}
})
// search for a firstname & company
index.search(Query(query: "jimmie paint"), completionHandler: { (content, error) -> Void in
	if error == nil {
		print("Result: \(content)")
	}
})
```

### Configure

Settings can be customized to tune the search behavior. For example, you can add a custom sort by number of followers to the already great built-in relevance:

```swift
let customRanking = ["desc(followers)"]
let settings = ["customRanking": customRanking]
index.setSettings(settings, completionHandler: { (content, error) -> Void in
	if error != nil {
		print("Error when applying settings: \(error!)")
	}
})
```

You can also configure the list of attributes you want to index by order of importance (first = most important):

**Note:** Since the engine is designed to suggest results as you type, you'll generally search by prefix.
In this case the order of attributes is very important to decide which hit is the best:

```swift
let customRanking = ["lastname", "firstname", "company", "email", "city", "address"]
let settings = ["searchableAttributes": customRanking]
index.setSettings(settings, completionHandler: { (content, error) -> Void in
	if error != nil {
		print("Error when applying settings: \(error!)")
	}
})
```

## Notes

### Previous Objective-C API Client

In July 2015, we released a **new version** of our Swift client, able to work with Swift and Objective-C.
As of version 3 (April 2016), Swift has become the reference implementation for both Swift and Objective-C projects.
The [Objective-C API Client](https://github.com/algolia/algoliasearch-client-objc) is no longer under active development.
It is still supported for bug fixes, but will not receive new features. If you were using our Objective-C client, read the [migration guide from Objective-C](https://github.com/algolia/algoliasearch-client-swift/wiki/Migration-guide-from-Objective-C-to-Swift-API-Client).

### Migration guides

If you were using **version 2.x** of our Swift client, read the [migration guide to version 3.x](https://github.com/algolia/algoliasearch-client-swift/wiki/Migration-guide-to-version-3.x).

### Swift 3

You can use this library with Swift by one of the following ways:

- `pod 'AlgoliaSearch-Client-Swift', '~> 4.8.1'`
- `pod 'AlgoliaSearch-Client-Swift', :git => 'https://github.com/algolia/algoliasearch-client-swift.git', :branch => 'swift-3'`

## Getting Help

- **Need help**? Ask a question to the [Algolia Community](https://discourse.algolia.com/) or on [Stack Overflow](http://stackoverflow.com/questions/tagged/algolia).
- **Found a bug?** You can open a [GitHub issue](https://github.com/algolia/algoliasearch-client-swift/issues).



