# Algolia Search API Client for Swift

[Algolia Search](https://www.algolia.com) is a hosted full-text, numerical,
and faceted search engine capable of delivering realtime results from the first keystroke.

The **Algolia Search API Client for Swift** lets
you easily use the [Algolia Search REST API](https://www.algolia.com/doc/rest-api/search) from
your Swift code.

[![Build Status](https://travis-ci.org/algolia/algoliasearch-client-swift.svg?branch=master)](https://travis-ci.org/algolia/algoliasearch-client-swift)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods](https://img.shields.io/cocoapods/v/AlgoliaSearch-Client-Swift.svg)]()
[![CocoaPods](https://img.shields.io/cocoapods/l/AlgoliaSearch-Client-Swift.svg)]()
[![](https://img.shields.io/badge/OS%20X-10.9%2B-lightgrey.svg)]()
[![](https://img.shields.io/badge/iOS-7.0%2B-lightgrey.svg)]()


You can browse the automatically generated [reference documentation](https://community.algolia.com/algoliasearch-client-swift/).
(See also the [offline-enabled version](https://community.algolia.com/algoliasearch-client-swift/offline/).)

**&lt;Welcome Objective-C developers&gt;**

In July 2015, we released a **new version** of our Swift client, able to work with Swift and Objective-C.
As of version 3 (April 2016), Swift has become the reference implementation for both Swift and Objective-C projects.
The [Objective-C API Client](https://github.com/algolia/algoliasearch-client-objc) is no longer under active development.
It is still supported for bug fixes, but will not receive new features.

If you were using our Objective-C client, read the [migration guide from Objective-C](https://github.com/algolia/algoliasearch-client-swift/wiki/Migration-guide-from-Objective-C-to-Swift-API-Client).

**&lt;/Welcome Objective-C developers&gt;**

If you were using **version 2.x** of our Swift client, read the [migration guide to version 3.x](https://github.com/algolia/algoliasearch-client-swift/wiki/Migration-guide-to-version-3.x).




## API Documentation

You can find the full reference on [Algolia's website](https://www.algolia.com/doc/api-client/swift/).


## Table of Contents



1. **[Supported platforms](#supported-platforms)**


1. **[Install](#install)**


1. **[Quick Start](#quick-start)**


1. **[Push data](#push-data)**


1. **[Configure](#configure)**


1. **[Search](#search)**


1. **[Search UI](#search-ui)**


1. **[List of available methods](#list-of-available-methods)**


# Getting Started



## Supported platforms

Our Swift client is supported on **iOS**, **macOS**, **tvOS** and **watchOS**,
and is usable from both **Swift** and **Objective-C**.

## Install

* Add a dependency on `AlgoliaSearch-Client-Swift`:
    - `CocoaPods`: add `pod 'AlgoliaSearch-Client-Swift'` to your `Podfile` for `Swift 4`
    - `CocoaPods`: add `pod 'AlgoliaSearch-Client-Swift', '~> 4.0'` to your `Podfile` for `Swift 3`
    - `Carthage`: add `github "algolia/algoliasearch-client-swift"` to your `Cartfile`
* Add `import AlgoliaSearch` to your source files

## Quick Start

In 30 seconds, this quick start tutorial will show you how to index and search objects.

### Initialize the client

To begin, you will need to initialize the client. In order to do this you will need your **Application ID** and **API Key**.
You can find both on [your Algolia account](https://www.algolia.com/api-keys).

```swift
let client = Client(appID: "YourApplicationID", apiKey: "YourAPIKey")
let index = client.index(withName: "your_index_name")
```

**Warning:** If you are building a native app on mobile, be sure to **not include** the search API key directly in the source code.
 You should instead consider [fetching the key from your servers](https://www.algolia.com/doc/guides/security/best-security-practices/#api-keys-in-mobile-applications)
 during the app's startup.

## Push data

Without any prior configuration, you can start indexing [500 contacts](https://github.com/algolia/datasets/blob/master/contacts/contacts.json) in the ```contacts``` index using the following code:

```swift
// Load content file
let jsonURL = Bundle.main.url(forResource: "contacts", withExtension: "json")
let jsonData = try! Data(contentsOf: jsonURL!)
let dict = try! JSONSerialization.jsonObject(with: jsonData!)

// Load all objects in the JSON file into an index named "contacts".
let index = client.index(withName: "contacts")
index.addObjects(dict["objects"])
```

## Configure

Settings can be customized to fine tune the search behavior. For example, you can add a custom sort by number of followers to further enhance the built-in relevance:

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

**Note:** The Algolia engine is designed to suggest results as you type, which means you'll generally search by prefix.
In this case, the order of attributes is very important to decide which hit is the best:

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

You can now search for contacts using `firstname`, `lastname`, `company`, etc. (even with typos):

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

## Search UI

**Warning:** If you are building a web application, you may be more interested in using one of our
[frontend search UI libraries](https://www.algolia.com/doc/guides/search-ui/search-libraries/)

The following example shows how to build a front-end search quickly using
[InstantSearch.js](https://community.algolia.com/instantsearch.js/)

### index.html

```html
<!doctype html>
<head>
  <meta charset="UTF-8">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/instantsearch.js@2.3/dist/instantsearch.min.css">
  <!-- Always use `2.x` versions in production rather than `2` to mitigate any side effects on your website,
  Find the latest version on InstantSearch.js website: https://community.algolia.com/instantsearch.js/v2/guides/usage.html -->
</head>
<body>
  <header>
    <div>
       <input id="search-input" placeholder="Search for products">
       <!-- We use a specific placeholder in the input to guides users in their search. -->
    
  </header>
  <main>
      
      
  </main>

  <script type="text/html" id="hit-template">
    
      <p class="hit-name">{{{_highlightResult.firstname.value}}} {{{_highlightResult.lastname.value}}}</p>
    
  </script>

  <script src="https://cdn.jsdelivr.net/npm/instantsearch.js@2.3/dist/instantsearch.min.js"></script>
  <script src="app.js"></script>
</body>
```

### app.js

```js
var search = instantsearch({
  // Replace with your own values
  appId: 'YourApplicationID',
  apiKey: 'YourSearchOnlyAPIKey', // search only API key, no ADMIN key
  indexName: 'contacts',
  urlSync: true,
  searchParameters: {
    hitsPerPage: 10
  }
});

search.addWidget(
  instantsearch.widgets.searchBox({
    container: '#search-input'
  })
);

search.addWidget(
  instantsearch.widgets.hits({
    container: '#hits',
    templates: {
      item: document.getElementById('hit-template').innerHTML,
      empty: "We didn't find any results for the search <em>\"{{query}}\"</em>"
    }
  })
);

search.start();
```




## List of available methods







### Search

- [Search an index](https://algolia.com/doc/api-reference/api-methods/search/?language=swift)
- [Search for facet values](https://algolia.com/doc/api-reference/api-methods/search-for-facet-values/?language=swift)
- [Search multiple indexes](https://algolia.com/doc/api-reference/api-methods/multiple-queries/?language=swift)
- [Browse an index](https://algolia.com/doc/api-reference/api-methods/browse/?language=swift)





### Indexing

- [Add objects](https://algolia.com/doc/api-reference/api-methods/add-objects/?language=swift)
- [Update objects](https://algolia.com/doc/api-reference/api-methods/update-objects/?language=swift)
- [Partial update objects](https://algolia.com/doc/api-reference/api-methods/partial-update-objects/?language=swift)
- [Delete objects](https://algolia.com/doc/api-reference/api-methods/delete-objects/?language=swift)
- [Delete by query](https://algolia.com/doc/api-reference/api-methods/delete-by-query/?language=swift)
- [Get objects](https://algolia.com/doc/api-reference/api-methods/get-objects/?language=swift)
- [Custom batch](https://algolia.com/doc/api-reference/api-methods/batch/?language=swift)
- [Wait for operations](https://algolia.com/doc/api-reference/api-methods/wait-task/?language=swift)





### Settings

- [Get settings](https://algolia.com/doc/api-reference/api-methods/get-settings/?language=swift)
- [Set settings](https://algolia.com/doc/api-reference/api-methods/set-settings/?language=swift)





### Manage indices

- [List indexes](https://algolia.com/doc/api-reference/api-methods/list-indices/?language=swift)
- [Delete index](https://algolia.com/doc/api-reference/api-methods/delete-index/?language=swift)
- [Copy index](https://algolia.com/doc/api-reference/api-methods/copy-index/?language=swift)
- [Move index](https://algolia.com/doc/api-reference/api-methods/move-index/?language=swift)
- [Clear index](https://algolia.com/doc/api-reference/api-methods/clear-index/?language=swift)





### API Keys

- [Create secured API Key](https://algolia.com/doc/api-reference/api-methods/generate-secured-api-key/?language=swift)















## Getting Help

- **Need help**? Ask a question to the [Algolia Community](https://discourse.algolia.com/) or on [Stack Overflow](http://stackoverflow.com/questions/tagged/algolia).
- **Found a bug?** You can open a [GitHub issue](https://github.com/algolia/algoliasearch-client-swift/issues).

