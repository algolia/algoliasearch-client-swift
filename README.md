# Algolia Search API Client for Swift

[Algolia Search](https://www.algolia.com) is a hosted search engine capable of delivering realtime results from the first keystroke.

The **Algolia Search API Client for Swift** lets
you easily use the [Algolia Search REST API](https://www.algolia.com/doc/rest-api/search) from
your Swift code.

[![Build Status](https://travis-ci.org/algolia/algoliasearch-client-swift.svg?branch=master)](https://travis-ci.org/algolia/algoliasearch-client-swift)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods](https://img.shields.io/cocoapods/v/AlgoliaSearch-Client-Swift.svg)]()
[![CocoaPods](https://img.shields.io/cocoapods/l/AlgoliaSearch-Client-Swift.svg)]()
[![](https://img.shields.io/badge/OS%20X-10.9%2B-lightgrey.svg)]()
[![](https://img.shields.io/badge/iOS-7.0%2B-lightgrey.svg)]()



  ## Contributing

  You can browse the automatically generated [reference documentation](https://community.algolia.com/algoliasearch-client-swift/).

**Upgrading**

If you were using **version 2.x** of our Swift client, read the [migration guide to version 3.x](https://github.com/algolia/algoliasearch-client-swift/wiki/Migration-guide-to-version-3.x).





## API Documentation

You can find the full reference on [Algolia's website](https://www.algolia.com/doc/api-client/swift/).



1. **[Supported platforms](#supported-platforms)**


1. **[Install](#install)**


1. **[Quick Start](#quick-start)**


1. **[Push data](#push-data)**


1. **[Configure](#configure)**


1. **[Search](#search)**


1. **[List of available methods](#list-of-available-methods)**


1. **[Objective-C developers](#objective-c-developers)**


1. **[Getting Help](#getting-help)**


1. **[List of available methods](#list-of-available-methods)**


# Getting Started



## Supported platforms

The API client is supported on **iOS**, **macOS**, **tvOS** and **watchOS**.
You can use it from both **Swift** and **Objective-C**.

## Install

* Add a dependency on `InstantSearchClient`:
    - `CocoaPods`: add `pod 'InstantSearchClient', '~> 6.0'` to your `Podfile` for `Swift 4.2`
    - `CocoaPods`: add `pod 'InstantSearchClient', '~> 5.0'` to your `Podfile` for `Swift 4.1`
    - `Carthage`: add `github "algolia/algoliasearch-client-swift" ~> 6.0.0` to your `Cartfile` for `Swift 4.2`
    - `Carthage`: add `github "algolia/algoliasearch-client-swift" ~> 5.0.0` to your `Cartfile` for `Swift 4.1`
* Add `import InstantSearchClient` to your source files

## Quick Start

In 30 seconds, this quick start tutorial will show you how to index and search objects.

### Initialize the client

To start, you need to initialize the client. To do this, you need your **Application ID** and **API Key**.
You can find both on [your Algolia account](https://www.algolia.com/api-keys).

```swift
let client = Client(appID: "YourApplicationID", apiKey: "YourAdminAPIKey")
let index = client.index(withName: "your_index_name")
```

**Warning:** If you are building a native app on mobile, make sure **not to include the search API key directly in the source code**.
You should instead consider [fetching the key from your servers](https://www.algolia.com/doc/guides/security/security-best-practices/#api-keys-in-mobile-applications)
during the app's startup.

## Push data

Without any prior configuration, you can start indexing [500 contacts](https://github.com/algolia/datasets/blob/master/contacts/contacts.json) in the ```contacts``` index using the following code:

```swift
// Load content file
let jsonURL = Bundle.main.url(forResource: "contacts", withExtension: "json")
let jsonData = try! Data(contentsOf: jsonURL!)
let dict = try! JSONSerialization.jsonObject(with: jsonData!)

// Load all objects in the JSON file into an index named "contacts"
let index = client.index(withName: "contacts")
index.addObjects(dict["objects"])
```

## Configure

You can customize settings to fine tune the search behavior. For example, you can add a custom ranking by number of followers to further enhance the built-in relevance:

```swift
let customRanking = ["desc(followers)"]
let settings = ["customRanking": customRanking]
index.setSettings(settings, completionHandler: { (content, error) -> Void in
    if error != nil {
        print("Error when applying settings: \(error!)")
    }
})
```

You can also configure the list of attributes you want to index by order of importance (most important first).

**Note:** Algolia is designed to suggest results as you type, which means you'll generally search by prefix.
In this case, the order of attributes is crucial to decide which hit is the best.

```swift
let customRanking = ["lastname", "firstname", "company", "email", "city", "address"]
let settings = ["searchableAttributes": customRanking]
index.setSettings(settings, completionHandler: { (content, error) -> Void in
    if error != nil {
        print("Error when applying settings: \(error!)")
    }
})
```

## Search

You can now search for contacts by `firstname`, `lastname`, `company`, etc. (even with typos):

```swift
// Search for a first name
index.search(Query(query: "jimmie"), completionHandler: { (content, error) -> Void in
    if error == nil {
        print("Result: \(content)")
    }
})
// Search for a first name with typo
index.search(Query(query: "jimie"), completionHandler: { (content, error) -> Void in
    if error == nil {
       print("Result: \(content)")
    }
})
// Search for a company
index.search(Query(query: "california paint"), completionHandler: { (content, error) -> Void in
    if error == nil {
       print("Result: \(content)")
    }
})
// Search for a first name and a company
index.search(Query(query: "jimmie paint"), completionHandler: { (content, error) -> Void in
    if error == nil {
        print("Result: \(content)")
    }
})
```




## List of available methods





### Personalization

- [Add strategy](https://algolia.com/doc/api-reference/api-methods/add-strategy/?language=swift)
- [Get strategy](https://algolia.com/doc/api-reference/api-methods/get-strategy/?language=swift)




### Search

- [Search index](https://algolia.com/doc/api-reference/api-methods/search/?language=swift)
- [Search for facet values](https://algolia.com/doc/api-reference/api-methods/search-for-facet-values/?language=swift)
- [Search multiple indices](https://algolia.com/doc/api-reference/api-methods/multiple-queries/?language=swift)
- [Browse index](https://algolia.com/doc/api-reference/api-methods/browse/?language=swift)




### Indexing

- [Add objects](https://algolia.com/doc/api-reference/api-methods/add-objects/?language=swift)
- [Save objects](https://algolia.com/doc/api-reference/api-methods/save-objects/?language=swift)
- [Partial update objects](https://algolia.com/doc/api-reference/api-methods/partial-update-objects/?language=swift)
- [Delete objects](https://algolia.com/doc/api-reference/api-methods/delete-objects/?language=swift)
- [Replace all objects](https://algolia.com/doc/api-reference/api-methods/replace-all-objects/?language=swift)
- [Delete by](https://algolia.com/doc/api-reference/api-methods/delete-by/?language=swift)
- [Clear objects](https://algolia.com/doc/api-reference/api-methods/clear-objects/?language=swift)
- [Get objects](https://algolia.com/doc/api-reference/api-methods/get-objects/?language=swift)
- [Custom batch](https://algolia.com/doc/api-reference/api-methods/batch/?language=swift)




### Settings

- [Get settings](https://algolia.com/doc/api-reference/api-methods/get-settings/?language=swift)
- [Set settings](https://algolia.com/doc/api-reference/api-methods/set-settings/?language=swift)
- [Copy settings](https://algolia.com/doc/api-reference/api-methods/copy-settings/?language=swift)




### Manage indices

- [List indices](https://algolia.com/doc/api-reference/api-methods/list-indices/?language=swift)
- [Delete index](https://algolia.com/doc/api-reference/api-methods/delete-index/?language=swift)
- [Copy index](https://algolia.com/doc/api-reference/api-methods/copy-index/?language=swift)
- [Move index](https://algolia.com/doc/api-reference/api-methods/move-index/?language=swift)




### API keys

- [Create secured API Key](https://algolia.com/doc/api-reference/api-methods/generate-secured-api-key/?language=swift)
- [Add API Key](https://algolia.com/doc/api-reference/api-methods/add-api-key/?language=swift)
- [Update API Key](https://algolia.com/doc/api-reference/api-methods/update-api-key/?language=swift)
- [Delete API Key](https://algolia.com/doc/api-reference/api-methods/delete-api-key/?language=swift)
- [Restore API Key](https://algolia.com/doc/api-reference/api-methods/restore-api-key/?language=swift)
- [Get API Key permissions](https://algolia.com/doc/api-reference/api-methods/get-api-key/?language=swift)
- [List API Keys](https://algolia.com/doc/api-reference/api-methods/list-api-keys/?language=swift)




### Synonyms

- [Save synonym](https://algolia.com/doc/api-reference/api-methods/save-synonym/?language=swift)
- [Batch synonyms](https://algolia.com/doc/api-reference/api-methods/batch-synonyms/?language=swift)
- [Delete synonym](https://algolia.com/doc/api-reference/api-methods/delete-synonym/?language=swift)
- [Clear all synonyms](https://algolia.com/doc/api-reference/api-methods/clear-synonyms/?language=swift)
- [Get synonym](https://algolia.com/doc/api-reference/api-methods/get-synonym/?language=swift)
- [Search synonyms](https://algolia.com/doc/api-reference/api-methods/search-synonyms/?language=swift)
- [Replace all synonyms](https://algolia.com/doc/api-reference/api-methods/replace-all-synonyms/?language=swift)
- [Copy synonyms](https://algolia.com/doc/api-reference/api-methods/copy-synonyms/?language=swift)
- [Export Synonyms](https://algolia.com/doc/api-reference/api-methods/export-synonyms/?language=swift)




### Query rules

- [Save rule](https://algolia.com/doc/api-reference/api-methods/save-rule/?language=swift)
- [Batch rules](https://algolia.com/doc/api-reference/api-methods/batch-rules/?language=swift)
- [Get rule](https://algolia.com/doc/api-reference/api-methods/get-rule/?language=swift)
- [Delete rule](https://algolia.com/doc/api-reference/api-methods/delete-rule/?language=swift)
- [Clear rules](https://algolia.com/doc/api-reference/api-methods/clear-rules/?language=swift)
- [Search rules](https://algolia.com/doc/api-reference/api-methods/search-rules/?language=swift)
- [Replace all rules](https://algolia.com/doc/api-reference/api-methods/replace-all-rules/?language=swift)
- [Copy rules](https://algolia.com/doc/api-reference/api-methods/copy-rules/?language=swift)
- [Export rules](https://algolia.com/doc/api-reference/api-methods/export-rules/?language=swift)




### A/B Test

- [Add A/B test](https://algolia.com/doc/api-reference/api-methods/add-ab-test/?language=swift)
- [Get A/B test](https://algolia.com/doc/api-reference/api-methods/get-ab-test/?language=swift)
- [List A/B tests](https://algolia.com/doc/api-reference/api-methods/list-ab-tests/?language=swift)
- [Stop A/B test](https://algolia.com/doc/api-reference/api-methods/stop-ab-test/?language=swift)
- [Delete A/B test](https://algolia.com/doc/api-reference/api-methods/delete-ab-test/?language=swift)




### Insights

- [Clicked Object IDs After Search](https://algolia.com/doc/api-reference/api-methods/clicked-object-ids-after-search/?language=swift)
- [Clicked Object IDs](https://algolia.com/doc/api-reference/api-methods/clicked-object-ids/?language=swift)
- [Clicked Filters](https://algolia.com/doc/api-reference/api-methods/clicked-filters/?language=swift)
- [Converted Objects IDs After Search](https://algolia.com/doc/api-reference/api-methods/converted-object-ids-after-search/?language=swift)
- [Converted Object IDs](https://algolia.com/doc/api-reference/api-methods/converted-object-ids/?language=swift)
- [Converted Filters](https://algolia.com/doc/api-reference/api-methods/converted-filters/?language=swift)
- [Viewed Object IDs](https://algolia.com/doc/api-reference/api-methods/viewed-object-ids/?language=swift)
- [Viewed Filters](https://algolia.com/doc/api-reference/api-methods/viewed-filters/?language=swift)




### MultiClusters

- [Assign or Move userID](https://algolia.com/doc/api-reference/api-methods/assign-user-id/?language=swift)
- [Get top userID](https://algolia.com/doc/api-reference/api-methods/get-top-user-id/?language=swift)
- [Get userID](https://algolia.com/doc/api-reference/api-methods/get-user-id/?language=swift)
- [List clusters](https://algolia.com/doc/api-reference/api-methods/list-clusters/?language=swift)
- [List userIDs](https://algolia.com/doc/api-reference/api-methods/list-user-id/?language=swift)
- [Remove userID](https://algolia.com/doc/api-reference/api-methods/remove-user-id/?language=swift)
- [Search userID](https://algolia.com/doc/api-reference/api-methods/search-user-id/?language=swift)




### Advanced

- [Get logs](https://algolia.com/doc/api-reference/api-methods/get-logs/?language=swift)
- [Configuring timeouts](https://algolia.com/doc/api-reference/api-methods/configuring-timeouts/?language=swift)
- [Set extra header](https://algolia.com/doc/api-reference/api-methods/set-extra-header/?language=swift)
- [Wait for operations](https://algolia.com/doc/api-reference/api-methods/wait-task/?language=swift)




### Vault




## Objective-C developers

In July 2015, we released a **new version** of our Swift client, able to work with Swift and Objective-C.
As of version 3 (April 2016), Swift has become the reference implementation for both Swift and Objective-C projects.
The [Objective-C API Client](https://github.com/algolia/algoliasearch-client-objc) is no longer under active development.
It is still supported for bug fixes, but will not receive new features.

If you were using our Objective-C client, read the [migration guide from Objective-C](https://github.com/algolia/algoliasearch-client-swift/wiki/Migration-guide-from-Objective-C-to-Swift-API-Client).


## Getting Help

- **Need help**? Ask a question to the [Algolia Community](https://discourse.algolia.com/) or on [Stack Overflow](http://stackoverflow.com/questions/tagged/algolia).
- **Found a bug?** You can open a [GitHub issue](https://github.com/algolia/algoliasearch-client-swift/issues).

