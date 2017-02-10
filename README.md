# Algolia Search API Client for Swift

[Algolia Search](https://www.algolia.com) is a hosted full-text, numerical, and faceted search engine capable of delivering realtime results from the first keystroke.
The **Algolia Search API Client for Swift** lets you easily use the [Algolia Search REST API](https://www.algolia.com/doc/rest-api/search) from your Swift code.

[![Build Status](https://travis-ci.org/algolia/algoliasearch-client-swift.svg?branch=master)](https://travis-ci.org/algolia/algoliasearch-client-swift)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods](https://img.shields.io/cocoapods/v/AlgoliaSearch-Client-Swift.svg)]()
[![CocoaPods](https://img.shields.io/cocoapods/l/AlgoliaSearch-Client-Swift.svg)]()
[![](https://img.shields.io/badge/OS%20X-10.9%2B-lightgrey.svg)]()
[![](https://img.shields.io/badge/iOS-7.0%2B-lightgrey.svg)]()


As a complement to this readme, you can browse the automatically generated [reference documentation](https://community.algolia.com/algoliasearch-client-swift/).
(See also the [offline-enabled version](https://community.algolia.com/algoliasearch-client-swift/offline/).)

**&lt;Welcome Objective-C developers&gt;**

In July 2015, we released a **new version** of our Swift client, able to work with Swift and Objective-C.
As of version 3 (April 2016), Swift has become the reference implementation for both Swift and Objective-C projects.
The [Objective-C API Client](https://github.com/algolia/algoliasearch-client-objc) is no longer under active development.
It is still supported for bug fixes, but will not receive new features.

If you were using our Objective-C client, read the [migration guide from Objective-C](https://github.com/algolia/algoliasearch-client-swift/wiki/Migration-guide-from-Objective-C-to-Swift-API-Client).

**&lt;/Welcome Objective-C developers&gt;**

If you were using **version 2.x** of our Swift client, read the [migration guide to version 3.x](https://github.com/algolia/algoliasearch-client-swift/wiki/Migration-guide-to-version-3.x).



**Note:** An easier-to-read version of this documentation is available on
[Algolia's website](https://www.algolia.com/doc/api-client/swift/).

# Table of Contents


**Getting Started**

1. [Supported platforms](#supported-platforms)
1. [Install](#install)
1. [Init index - `index`](#init-index---index)
1. [Quick Start](#quick-start)
1. [Getting Help](#getting-help)

**Search**

1. [Search an index - `search`](#search-an-index---search)
1. [Search Response Format](#search-response-format)
1. [Search Parameters](#search-parameters)
1. [Search multiple indices - `multipleQueries`](#search-multiple-indices---multiplequeries)
1. [Get Objects - `getObjects`](#get-objects---getobjects)
1. [Search for facet values - `searchForFacetValues`](#search-for-facet-values---searchforfacetvalues)
1. [Search cache](#search-cache)

**Indexing**

1. [Add Objects - `addObjects`](#add-objects---addobjects)
1. [Update objects - `saveObjects`](#update-objects---saveobjects)
1. [Partial update objects - `partialUpdateObjects`](#partial-update-objects---partialupdateobjects)
1. [Delete objects - `deleteObjects`](#delete-objects---deleteobjects)
1. [Delete by query - `deleteByQuery`](#delete-by-query---deletebyquery)
1. [Wait for operations - `waitTask`](#wait-for-operations---waittask)

**Settings**

1. [Get settings - `getSettings`](#get-settings---getsettings)
1. [Set settings - `setSettings`](#set-settings---setsettings)
1. [Index settings parameters](#index-settings-parameters)

**Parameters**

1. [Overview](#overview)
1. [Search](#search)
1. [Attributes](#attributes)
1. [Ranking](#ranking)
1. [Filtering / Faceting](#filtering--faceting)
1. [Highlighting / Snippeting](#highlighting--snippeting)
1. [Pagination](#pagination)
1. [Typos](#typos)
1. [Geo-Search](#geo-search)
1. [Query Strategy](#query-strategy)
1. [Performance](#performance)
1. [Advanced](#advanced)

**Manage Indices**

1. [Create an index](#create-an-index)
1. [List indices - `listIndexes`](#list-indices---listindexes)

**Advanced**

1. [Custom batch - `batch`](#custom-batch---batch)
1. [Backup / Export an index - `browse`](#backup--export-an-index---browse)
1. [REST API](#rest-api)


# Guides & Tutorials

Check our [online guides](https://www.algolia.com/doc):

* [Data Formatting](https://www.algolia.com/doc/indexing/formatting-your-data)
* [Import and Synchronize data](https://www.algolia.com/doc/indexing/import-synchronize-data/php)
* [Autocomplete](https://www.algolia.com/doc/search/auto-complete)
* [Instant search page](https://www.algolia.com/doc/search/instant-search)
* [Filtering and Faceting](https://www.algolia.com/doc/search/filtering-faceting)
* [Sorting](https://www.algolia.com/doc/relevance/sorting)
* [Ranking Formula](https://www.algolia.com/doc/relevance/ranking)
* [Typo-Tolerance](https://www.algolia.com/doc/relevance/typo-tolerance)
* [Geo-Search](https://www.algolia.com/doc/geo-search/geo-search-overview)
* [Security](https://www.algolia.com/doc/security/best-security-practices)
* [API-Keys](https://www.algolia.com/doc/security/api-keys)
* [REST API](https://www.algolia.com/doc/rest)


# Getting Started



## Supported platforms

Our Swift client is supported on **iOS**, **macOS**, **tvOS** and **watchOS**,
and is usable from both **Swift** and **Objective-C**.

## Install

1. Add a dependency on AlgoliaSearch-Client-Swift:
    - CocoaPods: add `pod 'AlgoliaSearch-Client-Swift', '~> 4.0'` to your `Podfile`.
    - Carthage: add `github "algolia/algoliasearch-client-swift"` to your `Cartfile`.
2. Add `import AlgoliaSearch` to your source files.

## Init index - `index` 

To initialize the client, you need your **Application ID** and **API Key**. You can find both of them on [your Algolia account](https://www.algolia.com/api-keys).

```swift
let client = Client(appID: "YourApplicationID", apiKey: "YourAPIKey")
```

## Quick Start

In 30 seconds, this quick start tutorial will show you how to index and search objects.

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

```swift
let customRanking = ["lastname", "firstname", "company", "email", "city", "address"]
let settings = ["searchableAttributes": customRanking]
index.setSettings(settings, completionHandler: { (content, error) -> Void in
	if error != nil {
		print("Error when applying settings: \(error!)")
	}
})
```

Since the engine is designed to suggest results as you type, you'll generally search by prefix. In this case the order of attributes is very important to decide which hit is the best:

```swift
index.search(Query(query: "or"), completionHandler: { (content, error) -> Void in
	if error == nil {
		print("Result: \(content)")
	}
})

index.search(Query(query: "jim"), completionHandler: { (content, error) -> Void in
	if error == nil {
		print("Result: \(content)")
	}
})
```

## Getting Help

- **Need help**? Ask a question to the [Algolia Community](https://discourse.algolia.com/) or on [Stack Overflow](http://stackoverflow.com/questions/tagged/algolia).
- **Found a bug?** You can open a [GitHub issue](https://github.com/algolia/algoliasearch-client-swift/issues).


# Search



## Search an index - `search` 

To perform a search, you only need to initialize the index and perform a call to the search function.

The search query allows only to retrieve 1000 hits. If you need to retrieve more than 1000 hits (e.g. for SEO), you can use [Backup / Export an index](#backup--export-an-index).

```swift
let index = client.index(withName: "contacts")
index.search(Query(query: "s"), completionHandler: { (content, error) -> Void in
  if error == nil {
      print("Result: \(content!)")
  }
})

let query = Query(query: "s")
query.attributesToRetrieve = ["firstname", "lastname"]
query.hitsPerPage = 50
index.search(query, completionHandler: { (content, error) -> Void in
  if error == nil {
      print("Result: \(content!)")
  }
})
```

## Search Response Format

### Sample

The server response will look like:

```json
{
  "hits": [
    {
      "firstname": "Jimmie",
      "lastname": "Barninger",
      "objectID": "433",
      "_highlightResult": {
        "firstname": {
          "value": "<em>Jimmie</em>",
          "matchLevel": "partial"
        },
        "lastname": {
          "value": "Barninger",
          "matchLevel": "none"
        },
        "company": {
          "value": "California <em>Paint</em> & Wlpaper Str",
          "matchLevel": "partial"
        }
      }
    }
  ],
  "page": 0,
  "nbHits": 1,
  "nbPages": 1,
  "hitsPerPage": 20,
  "processingTimeMS": 1,
  "query": "jimmie paint",
  "params": "query=jimmie+paint&attributesToRetrieve=firstname,lastname&hitsPerPage=50"
}
```

### Fields

- `hits` (array): The hits returned by the search, sorted according to the ranking formula.

    Hits are made of the JSON objects that you stored in the index; therefore, they are mostly schema-less. However, Algolia does enrich them with a few additional fields:

    - `_highlightResult` (object, optional): Highlighted attributes. *Note: Only returned when [attributesToHighlight](#attributestohighlight) is non-empty.*

        - `${attribute_name}` (object): Highlighting for one attribute.

            - `value` (string): Markup text with occurrences highlighted. The tags used for highlighting are specified via [highlightPreTag](#highlightpretag) and [highlightPostTag](#highlightposttag).

            - `matchLevel` (string, enum) = {`none` \| `partial` \| `full`}: Indicates how well the attribute matched the search query.

            - `matchedWords` (array): List of words *from the query* that matched the object.

            - `fullyHighlighted` (boolean): Whether the entire attribute value is highlighted.

    - `_snippetResult` (object, optional): Snippeted attributes. *Note: Only returned when [attributesToSnippet](#attributestosnippet) is non-empty.*

        - `${attribute_name}` (object): Snippeting for the corresponding attribute.

            - `value` (string): Markup text with occurrences highlighted and optional ellipsis indicators. The tags used for highlighting are specified via [highlightPreTag](#highlightpretag) and [highlightPostTag](#highlightposttag). The text used to indicate ellipsis is specified via [snippetEllipsisText](#snippetellipsistext).

            - `matchLevel` (string, enum) = {`none` \| `partial` \| `full`}: Indicates how well the attribute matched the search query.

    - `_rankingInfo` (object, optional): Ranking information. *Note: Only returned when [getRankingInfo](#getrankinginfo) is `true`.*

        - `nbTypos` (integer): Number of typos encountered when matching the record. Corresponds to the `typos` ranking criterion in the ranking formula.

        - `firstMatchedWord` (integer): Position of the most important matched attribute in the attributes to index list. Corresponds to the `attribute` ranking criterion in the ranking formula.

        - `proximityDistance` (integer): When the query contains more than one word, the sum of the distances between matched words. Corresponds to the `proximity` criterion in the ranking formula.

        - `userScore` (integer): Custom ranking for the object, expressed as a single numerical value. Conceptually, it's what the position of the object would be in the list of all objects sorted by custom ranking. Corresponds to the `custom` criterion in the ranking formula.

        - `geoDistance` (integer): Distance between the geo location in the search query and the best matching geo location in the record, divided by the geo precision.

        - `geoPrecision` (integer): Precision used when computed the geo distance, in meters. All distances will be floored to a multiple of this precision.

        - `nbExactWords` (integer): Number of exactly matched words. If `alternativeAsExact` is set, it may include plurals and/or synonyms.

        - `words` (integer): Number of matched words, including prefixes and typos.

        - `filters` (integer): *This field is reserved for advanced usage.* It will be zero in most cases.

        - `matchedGeoLocation` (object): Geo location that matched the query. *Note: Only returned for a geo search.*

            - `lat` (float): Latitude of the matched location.

            - `lng` (float): Longitude of the matched location.

            - `distance` (integer): Distance between the matched location and the search location (in meters). **Caution:** Contrary to `geoDistance`, this value is *not* divided by the geo precision.

    - `_distinctSeqID` (integer): *Note: Only returned when [distinct](#distinct) is non-zero.* When two consecutive results have the same value for the attribute used for "distinct", this field is used to distinguish between them.

- `nbHits` (integer): Number of hits that the search query matched.

- `page` (integer): Index of the current page (zero-based). See the [page](#page) search parameter. *Note: Not returned if you use `offset`/`length` for pagination.*

- `hitsPerPage` (integer): Maximum number of hits returned per page. See the [hitsPerPage](#hitsperpage) search parameter. *Note: Not returned if you use `offset`/`length` for pagination.*

- `nbPages` (integer): Number of pages corresponding to the number of hits. Basically, `ceil(nbHits / hitsPerPage)`. *Note: Not returned if you use `offset`/`length` for pagination.*

- `processingTimeMS` (integer): Time that the server took to process the request, in milliseconds. *Note: This does not include network time.*

- `query` (string): An echo of the query text. See the [query](#query) search parameter.

- `queryAfterRemoval` (string, optional): *Note: Only returned when [removeWordsIfNoResults](#removewordsifnoresults) is set to `lastWords` or `firstWords`.* A markup text indicating which parts of the original query have been removed in order to retrieve a non-empty result set. The removed parts are surrounded by `<em>` tags.

- `params` (string, URL-encoded): An echo of all search parameters.

- `message` (string, optional): Used to return warnings about the query.

- `aroundLatLng` (string, optional): *Note: Only returned when [aroundLatLngViaIP](#aroundlatlngviaip) is set.* The computed geo location. **Warning: for legacy reasons, this parameter is a string and not an object.** Format: `${lat},${lng}`, where the latitude and longitude are expressed as decimal floating point numbers.

- `automaticRadius` (integer, optional): *Note: Only returned for geo queries without an explicitly specified radius (see `aroundRadius`).* The automatically computed radius. **Warning: for legacy reasons, this parameter is a string and not an integer.**

When [getRankingInfo](#getrankinginfo) is set to `true`, the following additional fields are returned:

- `serverUsed` (string): Actual host name of the server that processed the request. (Our DNS supports automatic failover and load balancing, so this may differ from the host name used in the request.)

- `parsedQuery` (string): The query string that will be searched, after normalization. Normalization includes removing stop words (if [removeStopWords](#removestopwords) is enabled), and transforming portions of the query string into phrase queries (see [advancedSyntax](#advancedsyntax)).

- `timeoutCounts` (boolean) - DEPRECATED: Please use `exhaustiveFacetsCount` in remplacement.

- `timeoutHits` (boolean) - DEPRECATED: Please use `exhaustiveFacetsCount` in remplacement.

... and ranking information is also added to each of the hits (see above).

When [facets](#facets) is non-empty, the following additional fields are returned:

- `facets` (object): Maps each facet name to the corresponding facet counts:

    - `${facet_name}` (object): Facet counts for the corresponding facet name:

        - `${facet_value}` (integer): Count for this facet value.

- `facets_stats` (object, optional): *Note: Only returned when at least one of the returned facets contains numerical values.* Statistics for numerical facets:

    - `${facet_name}` (object): The statistics for a given facet:

        - `min` (integer | float): The minimum value in the result set.

        - `max` (integer | float): The maximum value in the result set.

        - `avg` (integer | float): The average facet value in the result set.

        - `sum` (integer | float): The sum of all values in the result set.

- `exhaustiveFacetsCount` (boolean): Whether the counts are exhaustive (`true`) or approximate (`false`). *Note: In some conditions when [distinct](#distinct) is greater than 1 and an empty query without refinement is sent, the facet counts may not always be exhaustive.*

## Search Parameters

You can see the full list of search parameters here:
[https://www.algolia.com/doc/api-client/swift/parameters/](https://www.algolia.com/doc/api-client/swift/parameters/)

## Search multiple indices - `multipleQueries` 

You can send multiple queries with a single API call using a batch of queries:

```swift
// Perform 3 queries in a single API call:
// 		- 1st query target index `categories`
//		- 2nd and 3rd queries target index `products`
let queries = [
    IndexQuery(indexName: "categories", query: Query(query: "electronics")),
    IndexQuery(indexName: "products", query: Query(query: "iPhone")),
    IndexQuery(indexName: "products", query: Query(query: "Galaxy"))
]
client.multipleQueries(queries, completionHandler: { (content, error) -> Void in
    if error == nil {
        print("Result: \(content!)")
    }
})
```

You can specify a `strategy` parameter to optimize your multiple queries:

- `none`: Execute the sequence of queries until the end.
- `stopIfEnoughMatches`: Execute the sequence of queries until the number of hits is reached by the sum of hits.

### Response

The resulting JSON contains the following fields:

- `results` (array): The results for each request, in the order they were submitted. The contents are the same as in [Search an index](#search-an-index).
    Each result also includes the following additional fields:

    - `index` (string): The name of the targeted index.
    - `processed` (boolean, optional): *Note: Only returned when `strategy` is `stopIfEnoughmatches`.* Whether the query was processed.

## Get Objects - `getObjects` 

You can easily retrieve an object using its `objectID` and optionally specify a comma separated list of attributes you want:

```swift
// Retrieve all attributes.
index.getObject(withID: "myID", completionHandler: { (content, error) -> Void in
  if error == nil {
      print("Object: \(content)")
  }
})
// Retrieve only the `firstname` attribute.
index.getObject(withID: "myID", attributesToRetrieve: ["firstname"], completionHandler: { (content, error) -> Void in
  if error == nil {
      print("Object: \(content)")
  }
})
```

You can also retrieve a set of objects:

```swift
index.getObjects(withIDs: ["myID1", "myID2"], completionHandler: { (content, error) -> {
  // do something
})
```

## Search for facet values - `searchForFacetValues` 

When there are many facet values for a given facet, it may be useful to search within them. For example, you may have dozens of 'brands' for a given index of 'clothes'. Rather than displaying all of the brands, it is often best to only display the most popular and add a search input to allow the user to search for the brand that they are looking for.

Searching on facet values is different than a regular search because you are searching only on *facet values*, not *objects*.

The results are sorted by decreasing count. By default, maximum 10 results are returned. This can be adjusted via [maxFacetHits](#maxfacethits). No pagination is possible.

The facet search can optionally take regular search query parameters.
In that case, it will return only facet values that both:

1. match the facet query
2. are contained in objects matching the regular search query.

**Warning:** For a facet to be searchable, it must have been declared with the `searchable()` modifier in the [attributesForFaceting](#attributesforfaceting) index setting.

#### Example

Let's imagine we have objects similar to this one:

```json
{
    "name": "iPhone 7 Plus",
    "brand": "Apple",
    "category": [
        "Mobile phones",
        "Electronics"
    ]
}
```

Then:

```swift
index.searchForFacetValues("category", for: "phone") { (content, error) in
    // Handle results
}
```

... could return:

```json
{
    "facetHits": [
        {
            "value": "Mobile phones",
            "highlighted": "Mobile <em>phone</em>s",
            "count": 507
        },
        {
            "value": "Phone cases",
            "highlighted": "<em>Phone</em> cases",
            "count": 63
        }
    ]
}
```

Let's filter with an additional, regular search query:

```swift
// Search the "category" facet for values matching "phone" in records
// having "Apple" in their "brand" facet.
let query = Query()
query.filters = "brand:Apple"
index.searchForFacetValues(of: "category", matching: "phone", query: query) { (content, error) in
    // Handle results
}
```

... could return:

```json
{
    "facetHits": [
        {
            "value": "Mobile phones",
            "highlighted": "Mobile <em>phone</em>s",
            "count": 41
        }
    ]
}
```

## Search cache

You can easily cache the results of the search queries by enabling the search cache.
The results will be cached during a defined amount of time (default: 2 min).
There is no pre-caching mechanism but you can simulate it by making a preemptive search query.

By default, the cache is disabled.

```swift
// Enable the search cache with default settings.
index.searchCacheEnabled = true
```

Or:

```swift
// Enable the search cache with a TTL of 5 minutes.
index.searchCacheEnabled = true
index.searchCacheExpiringTimeInterval = 300
```


# Indexing



## Add Objects - `addObjects` 

Each entry in an index has a unique identifier called `objectID`. There are two ways to add an entry to the index:

 1. Supplying your own `objectID`.
 2. Using automatic `objectID` assignment. You will be able to access it in the response.

Using your own unique IDs when creating records is a good way to make future updates easier without having to keep track of Algolia's generated IDs.
The value you provide for objectIDs can be an integer or a string.

You don't need to explicitly create an index, it will be automatically created the first time you add an object.
Objects are schema less so you don't need any configuration to start indexing.
If you wish to configure things, the settings section provides details about advanced settings.

Example with automatic `objectID` assignments:

```swift
let obj1 = ["firstname": "Jimmie", "lastname": "Barninger"]
let obj2 = ["firstname": "Warren", "lastname": "Speach"]
index.addObjects([obj1, obj2], completionHandler: { (content, error) -> Void in
    if error == nil {
        print("Object IDs: \(content!)")
    }
})
```

Example with manual `objectID` assignments:

```swift
let obj1 = ["objectID": "1", firstname": "Jimmie", "lastname": "Barninger"]
let obj2 = ["objectID": "2", "firstname": "Warren", "lastname": "Speach"]
index.addObjects([obj1, obj2], completionHandler: { (content, error) -> Void in
  if error == nil {
      print("Object IDs: \(content!)")
  }
})
```

To add a single object, use the following method:

```swift
let newObject = ["firstname": "Jimmie", "lastname": "Barninger"]
index.addObject(newObject, withID: "myID", completionHandler: { (content, error) -> Void in
  if error == nil {
      if let objectID = content!["objectID"] as? String {
          print("Object ID: \(objectID)")
      }
  }
})
```

## Update objects - `saveObjects` 

You have three options when updating an existing object:

 1. Replace all its attributes.
 2. Replace only some attributes.
 3. Apply an operation to some attributes.

Example on how to replace all attributes existing objects:

```swift
let obj1 = ["firstname": "Jimmie", "lastname": "Barninger", "objectID": "myID1"]
let obj2 = ["firstname": "Warren", "lastname": "Speach", "objectID": "myID2"]
index.saveObjects([obj1, obj2], completionHandler: { (content, error) -> Void in
  if error == nil {
      print("Object IDs: \(content!)")
  }
})
```

To update a single object, you can use the following method:

```swift
let newObject = [
  "firstname": "Jimmie",
  "lastname": "Barninger",
  "city": "New York",
  "objectID": "myID"
]
index.saveObject(newObject)
```

## Partial update objects - `partialUpdateObjects` 

You have many ways to update an object's attributes:

 1. Set the attribute value
 2. Add a string or number element to an array
 3. Remove an element from an array
 4. Add a string or number element to an array if it doesn't exist
 5. Increment an attribute
 6. Decrement an attribute

Example to update only the city attribute of an existing object:

```swift
let partialObject = ["city": "San Francisco"]
index.partialUpdateObject(partialObject, withID: "myID")
```

Example to add a tag:

```swift
let operation = [
  "value": "MyTag",
  "_operation": "Add"
]
let partialObject = ["_tags": operation]
index.partialUpdateObject(partialObject, withID: "myID")
```

Example to remove a tag:

```swift
let operation = [
  "value": "MyTag",
  "_operation": "Remove"
]
let partialObject = ["_tags": operation]
index.partialUpdateObject(partialObject, withID: "myID")
```

Example to add a tag if it doesn't exist:

```swift
let operation = [
  "value": "MyTag",
  "_operation": "AddUnique"
]
let partialObject = ["_tags": operation]
index.partialUpdateObject(partialObject, withID: "myID")
```

Example to increment a numeric value:

```swift
let operation = [
  "value": 42,
  "_operation": "Increment"
]
let partialObject = ["price": operation]
index.partialUpdateObject(partialObject, withID: "myID")
```

Note: Here we are incrementing the value by `42`. To increment just by one, put
`value:1`.

Example to decrement a numeric value:

```swift
let operation = [
  "value": 42,
  "_operation": "Decrement"
]
let partialObject = ["price": operation]
index.partialUpdateObject(partialObject, withID: "myID")
```

Note: Here we are decrementing the value by `42`. To decrement just by one, put
`value:1`.

To partial update multiple objects using one API call, you can use the following method:

```swift
let obj1 = ["firstname": "Jimmie", "objectID": "myID1"]
let obj2 = ["firstname": "Warren", "objectID": "myID2"]
index.partialUpdateObjects([obj1, obj2], completionHandler: { (content, error) -> Void in
  if error == nil {
      print("Object IDs: \(content!)")
  }
})
```

## Delete objects - `deleteObjects` 

You can delete objects using their `objectID`:

```swift
index.deleteObjects(withIDs: ["myID1", "myID2"])
```

To delete a single object, you can use the following method:

```swift
index.deleteObject(withID: "myID")
```

## Delete by query - `deleteByQuery` 

The "delete by query" helper deletes all objects matching a query. Internally, the API client will browse the index (as in [Backup / Export an index](#backup--export-an-index)), delete all matching hits, and wait until all deletion tasks have been applied.

**Warning:** Be careful when using this method. Calling it with an empty query will result in cleaning the index of all its records.

```swift
let query: Query = /* any browse-compatible query parameters */
index.deleteByQuery(query, completionHandler: { (content, error) -> Void in
    if error != nil {
        print("Error deleting objects")
    }
})
```

## Wait for operations - `waitTask` 

All write operations in Algolia are asynchronous by design.

It means that when you add or update an object to your index, our servers will
reply to your request with a `taskID` as soon as they understood the write
operation.

The actual insert and indexing will be done after replying to your code.

You can wait for a task to complete using the `waitTask` method on the `taskID` returned by a write operation.

For example, to wait for indexing of a new object:

```swift
index.addObject(newObject, completionHandler: { (content, error) -> Void in
    if error != nil {
        return
    }
    guard let taskID = content!["taskID"] as? Int else {
        return // could not retrieve task ID
    }
    self.index.waitTask(withID: taskID, completionHandler: { (content, error) -> Void in
        if error == nil {
            print("New object is indexed!")
        }
    })
})
```

If you want to ensure multiple objects have been indexed, you only need to check
the biggest `taskID`.


# Settings



## Get settings - `getSettings` 

You can retrieve settings:

```swift
index.getSettings(completionHandler: { (content, error) -> Void in
    if error == nil
        print("Settings: \(content!)")
    }
})
```

## Set settings - `setSettings` 

```swift
let customRanking = ["desc(followers)", "asc(name)"]
let settings = ["customRanking": customRanking]
index.setSettings(settings)
```

You can find the list of parameters you can set in the [Settings Parameters](#index-settings-parameters) section

**Warning**

Performance wise, it's better to do a `setSettings` before pushing the data

### Replica settings

You can forward all settings updates to the replicas of an index by using the `forwardToReplicas` option:

```swift
let settings = ["attributesToRetrieve": "name", "birthdate"]
index.setSettings(settings, forwardToReplicas: true, completionHandler: { (content, error) -> Void in
    // [...]
})
```

## Index settings parameters

You can see the full list of settings parameters here:
[https://www.algolia.com/doc/api-client/swift/parameters/](https://www.algolia.com/doc/api-client/swift/parameters/)


# Manage Indices



## Create an index

To create an index, you need to perform any indexing operation like:
- set settings
- add object

## List indices - `listIndexes` 

You can list all your indices along with their associated information (number of entries, disk size, etc.) with the `listIndexes` method:

```swift
client.listIndexes(completionHandler: { (content, error) -> Void in
    if error == nil {
        print("Indexes: \(content!)")
    }
})
```


# Advanced



## Custom batch - `batch` 

You may want to perform multiple operations with one API call to reduce latency.

If you have one index per user, you may want to perform a batch operations across several indices.
We expose a method to perform this type of batch:

```swift
let operations: [JSONObject] = [
  [
    "action": "addObject",
    "indexName": "index1",
    "body": [
      "firstname": "Jimmie",
      "lastname": "Barninger"
    ]
  ],
  [
    "action": "addObject",
    "indexName": "index2",
    "body": [
      "firstname": "Warren",
      "lastname": "Speach"
    ]
  ]
]
client.batch(operations: operations) {
  (content, error) in
  // Handle response
}
```

The attribute **action** can have these values:

- addObject
- updateObject
- partialUpdateObject
- partialUpdateObjectNoCreate
- deleteObject

## Backup / Export an index - `browse` 

The `search` method cannot return more than 1,000 results. If you need to
retrieve all the content of your index (for backup, SEO purposes or for running
a script on it), you should use the `browse` method instead. This method lets
you retrieve objects beyond the 1,000 limit.

This method is optimized for speed. To make it fast, distinct, typo-tolerance,
word proximity, geo distance and number of matched words are disabled. Results
are still returned ranked by attributes and custom ranking.

#### Response Format

##### Sample

```json
{
  "hits": [
    {
      "firstname": "Jimmie",
      "lastname": "Barninger",
      "objectID": "433"
    }
  ],
  "processingTimeMS": 7,
  "query": "",
  "params": "filters=level%3D20",
  "cursor": "ARJmaWx0ZXJzPWxldmVsJTNEMjABARoGODA4OTIzvwgAgICAgICAgICAAQ=="
}
```

##### Fields

- `cursor` (string, optional): A cursor to retrieve the next chunk of data. If absent, it means that the end of the index has been reached.
- `query` (string): Query text used to filter the results.
- `params` (string, URL-encoded): Search parameters used to filter the results.
- `processingTimeMS` (integer): Time that the server took to process the request, in milliseconds. *Note: This does not include network time.*

The following fields are provided for convenience purposes, and **only when the browse is not filtered**:

- `nbHits` (integer): Number of objects in the index.
- `page` (integer): Index of the current page (zero-based).
- `hitsPerPage` (integer): Maximum number of hits returned per page.
- `nbPages` (integer): Number of pages corresponding to the number of hits. Basically, `ceil(nbHits / hitsPerPage)`.

#### Example

Using the low-level methods:

```swift
index.browse(query: Query(), completionHandler: { (content, error) in
  if error != nil {
      return
  }
  // Handle content [...]
  // If there is more content...
  if let cursor = content!["cursor"] as? String {
      index.browse(from: cursor, completionHandler: { (content, error) in
          // Handle more content [...]
      })
  }
})
```

Using the browse helper:

```swift
let iterator = BrowseIterator(index: index, query: Query()) { (iterator, content, error) in
  // Handle the content/error [...]
  // You may cancel the iteration with:
  iterator.cancel()
}
iterator.start()
```

## REST API

We've developed API clients for the most common programming languages and platforms.
These clients are advanced wrappers on top of our REST API itself and have been made
in order to help you integrating the service within your apps:
for both indexing and search.

Everything that can be done using the REST API can be done using those clients.

The REST API lets your interact directly with Algolia platforms from anything that can send an HTTP request
[Go to the REST API doc](https://algolia.com/doc/rest)


