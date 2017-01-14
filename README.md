# Algolia Search API Client for Swift

[Algolia Search](https://www.algolia.com) is a hosted full-text, numerical, and faceted search engine capable of delivering realtime results from the first keystroke.
The **Algolia Search API Client for Swift** lets you easily use the [Algolia Search REST API](https://www.algolia.com/doc/rest-api/search) from your Swift code.

Our Swift client is supported on **iOS**, **macOS**, **tvOS** and **watchOS**,
and is usable from both **Swift** and **Objective-C**.

**&lt;Welcome Objective-C developers&gt;**

In July 2015, we released a **new version** of our Swift client, able to work with Swift and Objective-C.
As of version 3 (April 2016), Swift has become the reference implementation for both Swift and Objective-C projects.
The [Objective-C API Client](https://github.com/algolia/algoliasearch-client-objc) is no longer under active development.
It is still supported for bug fixes, but will not receive new features.

If you were using our Objective-C client, read the [migration guide from Objective-C](https://github.com/algolia/algoliasearch-client-swift/wiki/Migration-guide-from-Objective-C-to-Swift-API-Client).

**&lt;/Welcome Objective-C developers&gt;**

If you were using **version 2.x** of our Swift client, read the [migration guide to version 3.x](https://github.com/algolia/algoliasearch-client-swift/wiki/Migration-guide-to-version-3.x).

[![Build Status](https://travis-ci.org/algolia/algoliasearch-client-swift.svg?branch=master)](https://travis-ci.org/algolia/algoliasearch-client-swift)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods](https://img.shields.io/cocoapods/v/AlgoliaSearch-Client-Swift.svg)]()
[![CocoaPods](https://img.shields.io/cocoapods/l/AlgoliaSearch-Client-Swift.svg)]()
[![](https://img.shields.io/badge/OS%20X-10.9%2B-lightgrey.svg)]()
[![](https://img.shields.io/badge/iOS-7.0%2B-lightgrey.svg)]()


**Note:** An easier-to-read version of this documentation is available on
[Algolia's website](https://www.algolia.com/doc/api-client/swift/).

# Table of Contents


**Getting Started**

1. [Install](#install)
1. [Init index - `index`](#init-index---index)
1. [Quick Start](#quick-start)

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

Here is the list of parameters you can use with the search method (`search` [scope](#scope)):
Parameters that can also be used in a setSettings also have the `indexing` [scope](#scope)

**Search**

- [query](#query) `search`

**Attributes**

- [attributesToRetrieve](#attributestoretrieve) `settings`, `search`
- [restrictSearchableAttributes](#restrictsearchableattributes) `search`

**Filtering / Faceting**

- [filters](#filters) `search`
- [facets](#facets) `search`
- [maxValuesPerFacet](#maxvaluesperfacet) `settings`, `search`
- [facetFilters](#facetfilters) `search`

**Highlighting / Snippeting**

- [attributesToHighlight](#attributestohighlight) `settings`, `search`
- [attributesToSnippet](#attributestosnippet) `settings`, `search`
- [highlightPreTag](#highlightpretag) `settings`, `search`
- [highlightPostTag](#highlightposttag) `settings`, `search`
- [snippetEllipsisText](#snippetellipsistext) `settings`, `search`
- [restrictHighlightAndSnippetArrays](#restricthighlightandsnippetarrays) `settings`, `search`

**Pagination**

- [page](#page) `search`
- [hitsPerPage](#hitsperpage) `settings`, `search`
- [offset](#offset) `search`
- [length](#length) `search`

**Typos**

- [minWordSizefor1Typo](#minwordsizefor1typo) `settings`, `search`
- [minWordSizefor2Typos](#minwordsizefor2typos) `settings`, `search`
- [typoTolerance](#typotolerance) `settings`, `search`
- [allowTyposOnNumericTokens](#allowtyposonnumerictokens) `settings`, `search`
- [ignorePlurals](#ignoreplurals) `settings`, `search`
- [disableTypoToleranceOnAttributes](#disabletypotoleranceonattributes) `settings`, `search`

**Geo-Search**

- [aroundLatLng](#aroundlatlng) `search`
- [aroundLatLngViaIP](#aroundlatlngviaip) `search`
- [aroundRadius](#aroundradius) `search`
- [aroundPrecision](#aroundprecision) `search`
- [minimumAroundRadius](#minimumaroundradius) `search`
- [insideBoundingBox](#insideboundingbox) `search`
- [insidePolygon](#insidepolygon) `search`

**Query Strategy**

- [queryType](#querytype) `search`, `settings`
- [removeWordsIfNoResults](#removewordsifnoresults) `settings`, `search`
- [advancedSyntax](#advancedsyntax) `settings`, `search`
- [optionalWords](#optionalwords) `settings`, `search`
- [removeStopWords](#removestopwords) `settings`, `search`
- [exactOnSingleWordQuery](#exactonsinglewordquery) `settings`, `search`
- [alternativesAsExact](#alternativesasexact) `setting`, `search`

**Advanced**

- [distinct](#distinct) `settings`, `search`
- [getRankingInfo](#getrankinginfo) `search`
- [numericFilters](#numericfilters) `search`
- [tagFilters](#tagfilters) `search`
- [analytics](#analytics) `search`
- [analyticsTags](#analyticstags) `search`
- [synonyms](#synonyms) `search`
- [replaceSynonymsInHighlight](#replacesynonymsinhighlight) `settings`, `search`
- [minProximity](#minproximity) `settings`, `search`
- [responseFields](#responsefields) `settings`, `search`

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

When a facet can take many different values, it can be useful to search within them. The typical use case is to build
an autocomplete menu for facet refinements, but of course other use cases may apply as well.

The facet search is different from a regular search in the sense that it retrieves *facet values*, not *objects*.
In other words, a value will only be returned once, even if it matches many different objects. How many objects it
matches is indicated by a count.

The results are sorted by decreasing count. Maximum 10 results are returned. No pagination is possible.

The facet search can optionally be restricted by a regular search query. In that case, it will return only facet values
that both:

1. match the facet query; and
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
 2. Using automatic `objectID` assignment. You will be able to access it in the answer.

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

To add a single object, use the [Add Objects](#add-objects) method:

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

To partial update multiple objects using one API call, you can use the `[Partial update objects](#partial-update-objects)` method:

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

To delete a single object, you can use the `[Delete objects](#delete-objects)` method:

```swift
index.deleteObject(withID: "myID")
```

## Delete by query - `deleteByQuery` 

You can delete all objects matching a single query with the following code. Internally, the API client performs the query, deletes all matching hits, and waits until the deletions have been applied.

Take your precautions when using this method. Calling it with an empty query will result in cleaning the index of all its records.

```swift
let query: Query = /* [...] */
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

Here is the list of parameters you can use with the set settings method (`settings` [scope](#scope)).

Parameters that can be overridden at search time also have the `search` [scope](#scope).

**Attributes**

- [searchableAttributes](#searchableattributes) `settings`
- [attributesForFaceting](#attributesforfaceting) `settings`
- [unretrievableAttributes](#unretrievableattributes) `settings`
- [attributesToRetrieve](#attributestoretrieve) `settings`, `search`

**Ranking**

- [ranking](#ranking) `settings`
- [customRanking](#customranking) `settings`
- [replicas](#replicas) `settings`

**Filtering / Faceting**

- [maxValuesPerFacet](#maxvaluesperfacet) `settings`, `search`

**Highlighting / Snippeting**

- [attributesToHighlight](#attributestohighlight) `settings`, `search`
- [attributesToSnippet](#attributestosnippet) `settings`, `search`
- [highlightPreTag](#highlightpretag) `settings`, `search`
- [highlightPostTag](#highlightposttag) `settings`, `search`
- [snippetEllipsisText](#snippetellipsistext) `settings`, `search`
- [restrictHighlightAndSnippetArrays](#restricthighlightandsnippetarrays) `settings`, `search`

**Pagination**

- [hitsPerPage](#hitsperpage) `settings`, `search`
- [paginationLimitedTo](#paginationlimitedto) `settings`

**Typos**

- [minWordSizefor1Typo](#minwordsizefor1typo) `settings`, `search`
- [minWordSizefor2Typos](#minwordsizefor2typos) `settings`, `search`
- [typoTolerance](#typotolerance) `settings`, `search`
- [allowTyposOnNumericTokens](#allowtyposonnumerictokens) `settings`, `search`
- [ignorePlurals](#ignoreplurals) `settings`, `search`
- [disableTypoToleranceOnAttributes](#disabletypotoleranceonattributes) `settings`, `search`
- [disableTypoToleranceOnWords](#disabletypotoleranceonwords) `settings`
- [separatorsToIndex](#separatorstoindex) `settings`

**Query Strategy**

- [queryType](#querytype) `search`, `settings`
- [removeWordsIfNoResults](#removewordsifnoresults) `settings`, `search`
- [advancedSyntax](#advancedsyntax) `settings`, `search`
- [optionalWords](#optionalwords) `settings`, `search`
- [removeStopWords](#removestopwords) `settings`, `search`
- [disablePrefixOnAttributes](#disableprefixonattributes) `settings`
- [disableExactOnAttributes](#disableexactonattributes) `settings`
- [exactOnSingleWordQuery](#exactonsinglewordquery) `settings`, `search`

**Performance**

- [numericAttributesForFiltering](#numericattributesforfiltering) `settings`
- [allowCompressionOfIntegerArray](#allowcompressionofintegerarray) `settings`

**Advanced**

- [attributeForDistinct](#attributefordistinct) `settings`
- [distinct](#distinct) `settings`, `search`
- [replaceSynonymsInHighlight](#replacesynonymsinhighlight) `settings`, `search`
- [placeholders](#placeholders) `settings`
- [altCorrections](#altcorrections) `settings`
- [minProximity](#minproximity) `settings`, `search`
- [responseFields](#responsefields) `settings`, `search`


# Parameters



<section id="api-client-parameters-overview">

## Overview

### Scope

Each parameter in this page has a scope. Depending on the scope, you can use the parameter within the `setSettings`
and/or the `search` method.

There are three scopes:

- `settings`: The setting can only be used in the `setSettings` method.
- `search`: The setting can only be used in the `search` method.
- `settings` `search`: The setting can be used in the `setSettings` method and be overridden in the`search` method.

### Parameters List

**Search**

- [query](#query) `search`

**Attributes**

- [searchableAttributes](#searchableattributes) `settings`
- [attributesForFaceting](#attributesforfaceting) `settings`
- [unretrievableAttributes](#unretrievableattributes) `settings`
- [attributesToRetrieve](#attributestoretrieve) `settings`, `search`
- [restrictSearchableAttributes](#restrictsearchableattributes) `search`

**Ranking**

- [ranking](#ranking) `settings`
- [customRanking](#customranking) `settings`
- [replicas](#replicas) `settings`

**Filtering / Faceting**

- [filters](#filters) `search`
- [facets](#facets) `search`
- [maxValuesPerFacet](#maxvaluesperfacet) `settings`, `search`
- [facetFilters](#facetfilters) `search`

**Highlighting / Snippeting**

- [attributesToHighlight](#attributestohighlight) `settings`, `search`
- [attributesToSnippet](#attributestosnippet) `settings`, `search`
- [highlightPreTag](#highlightpretag) `settings`, `search`
- [highlightPostTag](#highlightposttag) `settings`, `search`
- [snippetEllipsisText](#snippetellipsistext) `settings`, `search`
- [restrictHighlightAndSnippetArrays](#restricthighlightandsnippetarrays) `settings`, `search`

**Pagination**

- [page](#page) `search`
- [hitsPerPage](#hitsperpage) `settings`, `search`
- [offset](#offset) `search`
- [length](#length) `search`
- [paginationLimitedTo](#paginationlimitedto) `settings`

**Typos**

- [minWordSizefor1Typo](#minwordsizefor1typo) `settings`, `search`
- [minWordSizefor2Typos](#minwordsizefor2typos) `settings`, `search`
- [typoTolerance](#typotolerance) `settings`, `search`
- [allowTyposOnNumericTokens](#allowtyposonnumerictokens) `settings`, `search`
- [ignorePlurals](#ignoreplurals) `settings`, `search`
- [disableTypoToleranceOnAttributes](#disabletypotoleranceonattributes) `settings`, `search`
- [disableTypoToleranceOnWords](#disabletypotoleranceonwords) `settings`
- [separatorsToIndex](#separatorstoindex) `settings`

**Geo-Search**

- [aroundLatLng](#aroundlatlng) `search`
- [aroundLatLngViaIP](#aroundlatlngviaip) `search`
- [aroundRadius](#aroundradius) `search`
- [aroundPrecision](#aroundprecision) `search`
- [minimumAroundRadius](#minimumaroundradius) `search`
- [insideBoundingBox](#insideboundingbox) `search`
- [insidePolygon](#insidepolygon) `search`

**Query Strategy**

- [queryType](#querytype) `search`, `settings`
- [removeWordsIfNoResults](#removewordsifnoresults) `settings`, `search`
- [advancedSyntax](#advancedsyntax) `settings`, `search`
- [optionalWords](#optionalwords) `settings`, `search`
- [removeStopWords](#removestopwords) `settings`, `search`
- [disablePrefixOnAttributes](#disableprefixonattributes) `settings`
- [disableExactOnAttributes](#disableexactonattributes) `settings`
- [exactOnSingleWordQuery](#exactonsinglewordquery) `settings`, `search`
- [alternativesAsExact](#alternativesasexact) `setting`, `search`

**Performance**

- [numericAttributesForFiltering](#numericattributesforfiltering) `settings`
- [allowCompressionOfIntegerArray](#allowcompressionofintegerarray) `settings`

**Advanced**

- [attributeForDistinct](#attributefordistinct) `settings`
- [distinct](#distinct) `settings`, `search`
- [getRankingInfo](#getrankinginfo) `search`
- [numericFilters](#numericfilters) `search`
- [tagFilters](#tagfilters) `search`
- [analytics](#analytics) `search`
- [analyticsTags](#analyticstags) `search`
- [synonyms](#synonyms) `search`
- [replaceSynonymsInHighlight](#replacesynonymsinhighlight) `settings`, `search`
- [placeholders](#placeholders) `settings`
- [altCorrections](#altcorrections) `settings`
- [minProximity](#minproximity) `settings`, `search`
- [responseFields](#responsefields) `settings`, `search`

## Search

#### query

- scope: `search`
- type: string
- default: `""`

The text to search for in the index. If empty or absent, the textual search will match any object.

## Attributes

#### searchableAttributes

- scope: `settings`
- type: array of strings
- default: `*` (all string attributes)
- formerly known as: `attributesToIndex`

The list of attributes you want index (i.e. to make searchable).

If set to null, all textual and numerical attributes of your objects are indexed.
Make sure you updated this setting to get optimal results.

This parameter has two important uses:

1. **Limit the attributes to index.** For example, if you store the URL of a picture, you want to store it and be able to retrieve it,
    but you probably don't want to search in the URL.

2. **Control part of the ranking.** The contents of the `searchableAttributes` parameter impacts ranking in two complementary ways:
    First, the order in which attributes are listed defines their ranking priority: matches in attributes at the beginning of the
    list will be considered more important than matches in attributes further down the list. To assign the same priority to several attributes,
    pass them within the same string, separated by commas. For example, by specifying `["title,"alternative_title", "text"]`,
    `title` and `alternative_title` will have the same priority, but a higher priority than `text`.

    Then, within the same attribute, matches near the beginning of the text will be considered more important than matches near the end.
    You can disable this behavior by wrapping your attribute name inside an `unordered()` modifier. For example, `["title", "unordered(text)"]`
    will consider all positions inside the `text` attribute as equal, but positions inside the `title` attribute will still matter.

    You can decide to have the same priority for several attributes by passing them in the same string using comma as separator.
    For example:
    `title` and `alternative_title` have the same priority in this example: `searchableAttributes:["title,alternative_title", "text"]`

**Note:** To get a full description of how the ranking works, you can have a look at our [Ranking guide](https://www.algolia.com/doc/guides/relevance/ranking).

#### attributesForFaceting

- scope: `settings`
- type: array of strings
- default: `[]`

List of attributes you want to use for faceting.

All strings within these attributes will be extracted and added as facets.
If not specified or empty, no attribute will be faceted.

If you only need to filter on a given facet, but are not interested in value counts for this facet,
you can improve performances by specifying `filterOnly(${attributeName})`. This decreases the size of the index
and the time required to build it.

If you want to search inside values of a given facet (using the [Search for facet values](#search-for-facet-values) method)
you need to specify `searchable(${attributeName})`.

**Note:** The `filterOnly()` and `searchable()` modifiers are mutually exclusive.

#### unretrievableAttributes

- scope: `settings`
- type: array of strings
- default: `[]`

List of attributes that cannot be retrieved at query time.

These attributes can still be used for indexing and/or ranking.

**Note:** This setting is bypassed when the query is authenticated with the **admin API key**.

#### attributesToRetrieve

- scope: `settings` `search`
- type: array of strings
- default: `*` (all attributes)
- formerly known as: `attributes`

List of object attributes you want to retrieve.
This can be used to minimize the size of the response.

You can use `*` to retrieve all values.

**Note:** `objectID` is always retrieved, even when not specified.

**Note:** Attributes listed in [unretrievableAttributes](#unretrievableattributes) will not be retrieved even if requested,
unless the request is authenticated with the admin API key.

#### restrictSearchableAttributes

- scope: `search`
- type: array of strings
- default: all attributes in `searchableAttributes`

List of attributes to be considered for textual search.

**Note:** It must be a subset of the [searchableAttributes](#searchableattributes) index setting.
Consequently, `searchableAttributes` must not be empty nor null for `restrictSearchableAttributes` to be allowed.

## Ranking

#### ranking

- scope: `settings`
- type: array of strings
- default: `["typo", "geo", "words", "filters", "proximity", "attribute", "exact", "custom"]`

Controls the way results are sorted.

You must specify a list of ranking criteria. They will be applied in sequence by the tie-breaking algorithm
in the order they are specified.

The following ranking criteria are available:

* `typo`: Sort by increasing number of typos.
* `geo`: Sort by decreasing geo distance when performing a geo search.
This criterion is ignored when not performing a geo search.
* `words`: Sort by decreasing number of matched query words.
This parameter is useful when you use the [optionalWords](#optionalwords) query parameter to rank hits with the most matched words first.
* `proximity`: Sort by increasing proximity of query words in hits.
* `attribute`: Sort according to the order of attributes defined by [searchableAttributes](#searchableattributes).
* `exact`:
    - **If the query contains only one word:** The behavior depends on the value of [exactOnSingleWordQuery](#exactonsinglewordquery).
    - **If the query contains multiple words:** Sort by decreasing number of words that matched exactly.
  What is considered to be an exact match depends on the value of [alternativesAsExact](#alternativesasexact).
* `custom`: Sort according to a user-defined formula specified via the [customRanking](#customranking) setting.
* Sort by value of a numeric attribute. Here, `${attributeName}` can be the name of any numeric attribute in your objects (integer, floating-point or boolean).
    * `asc(${attributeName})`: sort by increasing value of the attribute
    * `desc(${attributeName})`: sort by decreasing value of the attribute

**Note:** To get a full description of how the ranking works, you can have a look at our [Ranking guide](https://www.algolia.com/doc/guides/relevance/ranking).

#### customRanking

- scope: `settings`
- type: array of strings
- default: `[]`

Specifies the `custom` ranking criterion.

Each string must conform to the syntax `asc(${attributeName})` or `desc(${attributeName})` and specifies a
(respectively) increasing or decreasing sort on an attribute. All sorts are applied in sequence by the tie-breaking
algorithm in the order they are specified.

**Example:** `["desc(population)", "asc(name)"]` will sort by decreasing value of the `population` attribute,
then *in case of equality* by increasing value of the `name` attribute.

**Note:** To get a full description of how custom ranking works,
you can have a look at our [Ranking guide](https://www.algolia.com/doc/guides/relevance/ranking).

#### replicas

- scope: `settings`
- type: array of strings
- default: `[]`
- formerly known as: `slaves`

List of indices to which you want to replicate all write operations.

In order to get relevant results in milliseconds, we pre-compute part of the ranking during indexing.
Consequently, if you want to use different ranking formulas depending on the use case,
you need to create one index per ranking formula.

This option allows you to perform write operations on a single, master index and automatically
perform the same operations on all of its replicas.

**Note:** A master index can have as many replicas as needed. However, a replica can only have one master; in other words,
two master indices cannot have the same replica. Furthermore, a replica cannot have its own replicas
(i.e. you cannot "chain" replicas).

## Filtering / Faceting

#### filters

- scope: `search`
- type: string
- default: `""`

Filter the query with numeric, facet and/or tag filters.

This parameter uses a SQL-like expression syntax, where you can use boolean operators and parentheses to combine individual filters.

The following **individual filters** are supported:

- **Numeric filter**:

    - **Comparison**: `${attributeName} ${operator} ${operand}` matches all objects where the specified numeric attribute satisfies the numeric condition expressed by the operator and the operand. The operand must be a numeric value. Supported operators are `<`, `<=`, `=`, `!=`, `>=` and `>`, with the same semantics as in virtually all programming languages.
    Example: `inStock > 0`.

    - **Range**: `${attributeName}:${lowerBound} TO ${upperBound}` matches all objects where the specified numeric
    attribute is within the range [`${lowerBound}`, `${upperBound}`] (inclusive on both ends).
    Example: `publication_date: 1441745506 TO 1441755506`.

- **Facet filter**: `${facetName}:${facetValue}` matches all objects containing exactly the specified value in the specified facet attribute. *Facet matching is case sensitive*. Example: `category:Book`.

- **Tag filter**: `_tags:${value}` (or, alternatively, just `${value}`) matches all objects containing exactly the specified value in their `_tags` attribute. *Tag matching is case sensitive*. Example: `_tags:published`.

Individual filters can be combined via **boolean operators**. The following operators are supported:

- `OR`: must match any of the combined conditions (disjunction)
- `AND`: must match all of the combined conditions (conjunction)
- `NOT`: negate a filter

Finally, **parentheses** (`(` and `)`) can be used for grouping.

Putting it all together, an example is:

```
available = 1 AND (category:Book OR NOT category:Ebook) AND _tags:published AND publication_date:1441745506 TO 1441755506 AND inStock > 0 AND author:"John Doe"
```

**Warning:** Keywords are case-sensitive.

**Note:** If no attribute name is specified, the filter applies to `_tags`.
For example: `public OR user_42` will translate into `_tags:public OR _tags:user_42`.

**Note:** If a value contains spaces, or conflicts with a keyword, you can use double quotes.

**Note:** If a filtered attribute contains an array of values, any matching value will cause the filter to match.

**Warning:** For performance reasons, filter expressions are limited to a disjunction of conjunctions.
In other words, you can have ANDs of ORs (e.g. `filter1 AND (filter2 OR filter3)`),
but not ORs of ANDs (e.g. `filter1 OR (filter2 AND filter3)`.

**Warning:** You cannot mix different filter categories inside a disjunction (OR).
For example, `num=3 OR tag1 OR facet:value` is not allowed.

**Warning:** You cannot negate a group of filters, only an individual filter.
For example, `NOT(filter1 OR filter2)` is not allowed.

#### facets

- scope: `search`
- type: array of strings
- default: `[]`

Facets to retrieve.
If not specified or empty, no facets are retrieved.
The special value `*` may be used to retrieve all facets.

**Warning:** Facets must have been declared beforehand in the [attributesForFaceting](#attributesforfaceting) index setting.

For each of the retrieved facets, the response will contain a list of the most frequent facet values in objects
matching the current query. Each value will be returned with its associated count (number of matched objects containing that value).

**Warning:** Faceting does **not** filter your results. If you want to filter results, you should use [filters](#filters).

**Example**:

If your settings contain:

```
{
  "attributesForFaceting": ["category", "author", "nb_views", "nb_downloads"]
}
```

... but, for the current search, you want to retrieve facet values only for `category` and `author`, then you can specify:

```
"facets": ["category", "author"]
```

**Warning:** If the number of hits is high, facet counts may be approximate.
The response field `exhaustiveFacetsCount` is true when the count is exact.

#### maxValuesPerFacet

- scope: `settings` `search`
- type: integer
- default: `100`

Maximum number of facet values returned for each facet.

**Warning:** The API enforces a hard limit of 1000 on `maxValuesPerFacet`.
Any value above that limit will be interpreted as 1000.

#### facetFilters

- scope: `search`
- type: array of strings
- default: `[]`

Filter hits by facet value.

**Note:** The [filters](#filters) parameter provides an easier to use, SQL-like syntax.
We recommend using it instead of `facetFilters`.

Each string represents a filter on a given facet value. It must follow the syntax `${attributeName}:${value}`.

If you specify multiple filters, they are interpreted as a conjunction (AND). If you want to use a disjunction (OR),
use a nested array.

Examples:

- `["category:Book", "author:John Doe"]` translates as `category:Book AND author:"John Doe"`
- `[["category:Book", "category:Movie"], "author:John Doe"]` translates as `(category:Book OR category:Movie) AND author:"John Doe"`

Negation is supported by prefixing the value with a minus sign (`-`, a.k.a. dash).
For example: `["category:Book", "category:-Movie"]` translates as `category:Book AND NOT category:Movie`.

## Highlighting / Snippeting

#### attributesToHighlight

- scope: `settings` `search`
- type: array of strings
- default: all searchable attributes

List of attributes to highlight.
If set to null, all **searchable** attributes are highlighted (see [searchableAttributes](#searchableattributes)).
The special value `*` may be used to highlight all attributes.

**Note:** Only string values can be highlighted. Numerics will be ignored.

When highlighting is enabled, each hit in the response will contain an additional `_highlightResult` object
(provided that at least one of its attributes is highlighted) with the following fields:

<!-- TODO: Factorize the following with the "Search Response Format" section in the API Client doc. -->

- `value` (string): Markup text with occurrences highlighted.
  The tags used for highlighting are specified via [highlightPreTag](#highlightpretag) and [highlightPostTag](#highlightposttag).

- `matchLevel` (string, enum) = {`none` \| `partial` \| `full`}: Indicates how well the attribute matched the search query.

- `matchedWords` (array): List of words *from the query* that matched the object.

- `fullyHighlighted` (boolean): Whether the entire attribute value is highlighted.

#### attributesToSnippet

- scope: `settings` `search`
- type: array of strings
- default: `[]` (no attribute is snippeted)

List of attributes to snippet, with an optional maximum number of words to snippet.
If set to null, no attributes are snippeted.
The special value `*` may be used to snippet all attributes.

The syntax for each attribute is `${attributeName}:${nbWords}`.
The number of words can be omitted, and defaults to 10.

**Note:** Only string values can be snippeted. Numerics will be ignored.

When snippeting is enabled, each hit in the response will contain an additional `_snippetResult` object
(provided that at least one of its attributes is snippeted) with the following fields:

<!-- TODO: Factorize the following with the "Search Response Format" section in the API Client doc. -->

- `value` (string): Markup text with occurrences highlighted and optional ellipsis indicators.
  The tags used for highlighting are specified via [highlightPreTag](#highlightpretag) and [highlightPostTag](#highlightposttag).
  The text used to indicate ellipsis is specified via [snippetEllipsisText](#snippetellipsistext).

- `matchLevel` (string, enum) = {`none` \| `partial` \| `full`}: Indicates how well the attribute matched the search query.

#### highlightPreTag

- scope: `settings` `search`
- type: string
- default: `"<em>"`

String inserted before highlighted parts in highlight and snippet results.

#### highlightPostTag

- scope: `settings` `search`
- type: string
- default: `"</em>"`

String inserted after highlighted parts in highlight and snippet results.

#### snippetEllipsisText

- scope: `settings` `search`
- type: string
- default: `…` (U+2026)

String used as an ellipsis indicator when a snippet is truncated.

**Warning:** Defaults to an empty string for all accounts created before February 10th, 2016.
Defaults to `…` (U+2026, HORIZONTAL ELLIPSIS) for accounts created after that date.

#### restrictHighlightAndSnippetArrays

- scope: `settings` `search`
- type: boolean
- default: `false`

When true, restrict arrays in highlight and snippet results to items that matched the query at least partially.
When false, return all array items in highlight and snippet results.

## Pagination

#### page

- scope: `search`
- type: integer
- default: `0`

Number of the page to retrieve.

**Warning:** Page numbers are zero-based. Therefore, in order to retrieve the 10th page, you need to set `page=9`.

#### hitsPerPage

- scope: `settings` `search`
- type: integer
- default: `20`

Maximum number of hits per page.

#### offset

- scope: `search`
- type: integer
- default: `null`

Offset of the first hit to return (zero-based).

**Note:** In most cases, [page](#page)/[hitsPerPage](#hitsperpage) is the recommended method for pagination.

#### length

- scope: `search`
- type: integer
- default: `null`

Maximum number of hits to return.

**Note:** In most cases, [page](#page)/[hitsPerPage](#hitsperpage) is the recommended method for pagination.

#### paginationLimitedTo

- scope: `settings`
- type: integer
- default: `1000`

Maximum number of hits accessible via pagination.
By default, this parameter is set to 1000 to guarantee good performance.

**Caution:** We recommend keeping the default value to guarantee excellent performance.
Increasing the pagination limit will have a direct impact on the performance of search queries.
A too high value will also make it very easy for anyone to retrieve ("scrape") your entire dataset.

## Typos

#### minWordSizefor1Typo

- scope: `settings` `search`
- type: integer
- default: `4`

Minimum number of characters a word in the query string must contain to accept matches with one typo.

#### minWordSizefor2Typos

- scope: `settings` `search`
- type: integer
- default: `8`

Minimum number of characters a word in the query string must contain to accept matches with two typos.

#### typoTolerance

- scope: `settings` `search`
- type: string \| boolean
- default: `true`

Controls whether typo tolerance is enabled and how it is applied:

* `true`:
  Typo tolerance is enabled and all matching hits are retrieved (default behavior).

* `false`:
  Typo tolerance is entirely disabled. Hits matching with only typos are not retrieved.

* `min`:
  Only keep results with the minimum number of typos. For example, if just one hit matches without typos, then all hits with only typos are not retrieved.

* `strict`:
  Hits matching with 2 typos or more are not retrieved if there are some hits matching without typos.
  This option is useful to avoid "false positives" as much as possible.

#### allowTyposOnNumericTokens

- scope: `settings` `search`
- type: boolean
- default: `true`

Whether to allow typos on numbers ("numeric tokens") in the query string.

When false, typo tolerance is disabled on numeric tokens.
For example, the query `304` will match `30450` but not `40450`
(which would have been the case with typo tolerance enabled).

**Note:** This option can be very useful on serial numbers and zip codes searches.

#### ignorePlurals

- scope: `settings` `search`
- type: boolean \| array of strings
- default: `false`

Consider singular and plurals forms a match without typo.
For example, "car" and "cars", or "foot" and "feet" will be considered equivalent.

This parameter may be:

- a **boolean**: enable or disable plurals for all supported languages;
- a **list of language ISO codes** for which plurals should be enabled.

This option is set to `false` by default.

List of supported languages with their associated ISO code:

Afrikaans=`af`, Arabic=`ar`, Azeri=`az`, Bulgarian=`bg`, Catalan=`ca`,
Czech=`cs`, Welsh=`cy`, Danis=`da`, German=`de`, English=`en`,
Esperanto=`eo`, Spanish=`es`, Estonian=`et`, Basque=`eu`, Finnish=`fi`,
Faroese=`fo`, French=`fr`, Galician=`gl`, Hebrew=`he`, Hindi=`hi`,
Hungarian=`hu`, Armenian=`hy`, Indonesian=`id`, Icelandic=`is`, Italian=`it`,
Japanese=`ja`, Georgian=`ka`, Kazakh=`kk`, Korean=`ko`, Kyrgyz=`ky`,
Lithuanian=`lt`, Maori=`mi`, Mongolian=`mn`, Marathi=`mr`, Malay=`ms`,
Maltese=`mt`, Norwegian=`nb`, Dutch=`nl`, Northern Sotho=`ns`, Polish=`pl`,
Pashto=`ps`, Portuguese=`pt`, Quechua=`qu`, Romanian=`ro`, Russian=`ru`,
Slovak=`sk`, Albanian=`sq`, Swedish=`sv`, Swahili=`sw`, Tamil=`ta`,
Telugu=`te`, Tagalog=`tl`, Tswana=`tn`, Turkish=`tr`, Tatar=`tt`

#### disableTypoToleranceOnAttributes

- scope: `settings` `search`
- type: array of strings
- default: `[]`

List of attributes on which you want to disable typo tolerance
(must be a subset of the [searchableAttributes](#searchableattributes) index setting).

#### disableTypoToleranceOnWords

- scope: `settings`
- type: array of strings
- default: `[]`

List of words on which typo tolerance will be disabled.

#### separatorsToIndex

- scope: `settings`
- type: string
- default: `""`

Separators (punctuation characters) to index.

By default, separators are not indexed.

**Example:** Use `+#` to be able to search for "Google+" or "C#".

## Geo-Search

Geo search requires that you provide at least one geo location in each record at indexing time, under the `_geoloc` attribute. Each location must be an object with two numeric `lat` and `lng` attributes. You may specify either one location:

```json
{
  "_geoloc": {
    "lat": 48.853409,
    "lng": 2.348800
  }
}
```

... or an array of locations:

```json
{
  "_geoloc": [
    {
      "lat": 48.853409,
      "lng": 2.348800
    },
    {
      "lat": 48.547456,
      "lng": 2.972075
    }
  ]
}
```

When performing a geo search (either via <%= parameter_link('aroundLatLng') -%> or <%= parameter_link('aroundLatLngViaIP') -%>),
the maximum distance is automatically guessed based on the density of the searched area.
You may explicitly specify a maximum distance, however, via <%= parameter_link('aroundRadius') -%>.

The precision for the ranking is set via <%= parameter_link('aroundPrecision') -%>.

#### aroundLatLng

- scope: `search`
- type: (latitude, longitude) pair
- default: `null`

Search for entries around a given location (specified as two floats separated by a comma).

For example, `aroundLatLng=47.316669,5.016670`.

<!-- TODO: Only document serialization format for the REST API. -->

#### aroundLatLngViaIP

- scope: `search`
- type: boolean
- default: `false`

Search for entries around a given location automatically computed from the requester's IP address.

**Warning:** If you are sending the request from your servers, you must set the `X-Forwarded-For` HTTP header with the client's IP
address for it to be used as the basis for the computation of the search location.

#### aroundRadius

- scope: `search`
- type: integer \| `"all"`
- default: `null`

Maximum radius for geo search (in meters).

If set, only hits within the specified radius from the searched location will be returned.

If not set, the radius is automatically computed from the density of the searched area.
You can retrieve the computed radius in the `automaticRadius` response field.
You may also specify a minimum value for the automatic radius via [minimumAroundRadius](#minimumaroundradius).

The special value `all` causes the geo distance to be computed and taken into account for ranking, but without filtering;
this option is faster than specifying a high integer value.

#### aroundPrecision

- scope: `search`
- type: integer
- default: `1`

Precision of geo search (in meters).

When ranking hits, geo distances are grouped into ranges of `aroundPrecision` size. All hits within the same range
are considered equal with respect to the `geo` ranking parameter.

For example, if you set `aroundPrecision` to `100`, any two objects lying in the range `[0, 99m]` from the searched
location will be considered equal; same for `[100, 199]`, `[200, 299]`, etc.

#### minimumAroundRadius

- scope: `search`
- type: integer
- default: `null`

Minimum radius used for a geo search when [aroundRadius](#aroundradius) is not set.

**Note:** This parameter is ignored when `aroundRadius` is set.

#### insideBoundingBox

- scope: `search`
- type: geo rectangle(s)
- default: `null`

Search inside a rectangular area (in geo coordinates).

The rectange is defined by two diagonally opposite points (hereafter `p1` and `p2`),
hence by 4 floats: `p1Lat`, `p1Lng`, `p2Lat`, `p2Lng`.

For example:

- `searchInsideBoundingBoxWithLatitudeP1(47.3165, 4.9665, 47.3424, 5.0201)`

You may specify multiple bounding boxes, in which case the search will use the **union** (OR) of the rectangles.
To specify multiple rectangles, pass either:

- more than 4 values (must be a multiple of 4: 8, 12...);
  example: `47.3165,4.9665,47.3424,5.0201,40.9234,2.1185,38.6430,1.9916`; or
- an array of arrays of floats (each inner array must contain exactly 4 values);
  example: `[[47.3165, 4.9665, 47.3424, 5.0201], [40.9234, 2.1185, 38.6430, 1.9916]`.

#### insidePolygon

- scope: `search`
- type: geo polygon(s)
- default: `null`

Search inside a polygon (in geo coordinates).

The polygon is defined by a set of points (minimum 3), each defined by its latitude and longitude.
You therefore need an even number of floats, with a minimum of 6: `p1Lat`, `p1Lng`, `p2Lat`, `p2Lng`, `p3Lat`, `p3Long`.

For example:

- `searchInsidePolygon(47.3165, 4.9665, 47.3424, 5.0201, 47.32, 4.98)`

You may specify multiple polygons, in which case the search will use the **union** (OR) of the polygons.
To specify multiple polygons, pass an array of arrays of floats (each inner array must contain an even number of
values, with a minimum of 6);
example: `[[47.3165, 4.9665, 47.3424, 5.0201, 47.32, 4.9], [40.9234, 2.1185, 38.6430, 1.9916, 39.2587, 2.0104]]`.

## Query Strategy

#### queryType

- scope: `search` `settings`
- type: string
- default: `"prefixLast"`

Controls if and how query words are interpreted as prefixes.

It may be one of the following values:

* `prefixLast`:
  Only the last word is interpreted as a prefix (default behavior).

* `prefixAll`:
  All query words are interpreted as prefixes. This option is not recommended.

* `prefixNone`:
  No query word is interpreted as a prefix. This option is not recommended.

#### removeWordsIfNoResults

- scope: `settings` `search`
- type: string
- default: `"none"`

Selects a strategy to remove words from the query when it doesn't match any hits.

The goal is to avoid empty results by progressively loosening the query until hits are matched.

There are four different options:

- `none`:
  No specific processing is done when a query does not return any results (default behavior).

- `lastWords`:
  When a query does not return any results, treat the last word as optional.
  The process is repeated with words N-1, N-2, etc. until there are results, or the beginning of the query string has been reached.

- `firstWords`:
  When a query does not return any results, treat the first word as optional.
  The process is repeated with words 2, 3, etc. until there are results, or the end of the query string has been reached.

- `allOptional`:
  When a query does not return any results, make a second attempt treating all words as optional.
  This is equivalent to transforming the implicit AND operator applied between query words to an OR.

#### advancedSyntax

- scope: `settings` `search`
- type: boolean
- default: `false`

Enables the advanced query syntax.

This advanced syntax brings two additional features:

- **Phrase query**: a specific sequence of terms that must be matched next to one another.
  A phrase query needs to be surrounded by double quotes (`"`).
  For example, `"search engine"` will only match records having `search` next to `engine`.

  Typo tolerance is disabled inside the phrase (i.e. within the quotes).
  

- **Prohibit operator**: excludes records that contain a specific term.
  This term has to be prefixed by a minus (`-`, a.k.a dash).
  For example, `search -engine` will only match records containing `search` but not `engine`.

#### optionalWords

- scope: `settings` `search`
- type: string \| array of strings
- default: `[]`

List of words that should be considered as optional when found in the query.

**Note:** You don't need to put commas between words.
Each string will automatically be tokenized into words, all of which will be considered as optional.

#### removeStopWords

- scope: `settings` `search`
- type: boolean \| array of strings
- default: `false`

Remove stop words from the query **before** executing it.

This parameter may be:

- a **boolean**: enable or disable stop words for all supported languages; or
- a **list of language ISO codes** for which stop word removal should be enabled.

**Warning:** In most use-cases, **we don't recommend enabling stop word removal**.

Stop word removal is useful when you have a query in natural language, e.g. "what is a record?".
In that case, the engine will remove "what", "is" and "a" before executing the query, and therefore just search for "record".
This will remove false positives caused by stop words, especially when combined with optional words
(see [optionalWords](#optionalwords) and [removeWordsIfNoResults](#removewordsifnoresults)).
For most use cases, however, it is better not to use this feature, as people tend to search by keywords on search engines
(i.e. they naturally omit stop words).

**Note:** Stop words removal is only applied on query words that are *not* interpreted as prefixes.

As a consequence, the behavior of `removeStopWords` also depends on the [queryType](#querytype) parameter:

* `queryType=prefixLast` means the last query word is a prefix and won't be considered for stop word removal;
* `queryType=prefixNone` means no query word is a prefix, therefore stop word removal will be applied to all query words;
* `queryType=prefixAll` means all query words are prefixes, therefore no stop words will be removed.

List of supported languages with their associated ISO code:

Arabic=`ar`, Armenian=`hy`, Basque=`eu`, Bengali=`bn`, Brazilian=`pt-br`, Bulgarian=`bg`, Catalan=`ca`, Chinese=`zh`, Czech=`cs`, Danish=`da`, Dutch=`nl`, English=`en`, Finnish=`fi`, French=`fr`, Galician=`gl`, German=`de`, Greek=`el`, Hindi=`hi`, Hungarian=`hu`, Indonesian=`id`, Irish=`ga`, Italian=`it`, Japanese=`ja`, Korean=`ko`, Kurdish=`ku`, Latvian=`lv`, Lithuanian=`lt`, Marathi=`mr`, Norwegian=`no`, Persian (Farsi)=`fa`, Polish=`pl`, Portugese=`pt`, Romanian=`ro`, Russian=`ru`, Slovak=`sk`, Spanish=`es`, Swedish=`sv`, Thai=`th`, Turkish=`tr`, Ukranian=`uk`, Urdu=`ur`.

#### disablePrefixOnAttributes

- scope: `settings`
- type: array of strings
- default: `[]`

List of attributes on which you want to disable prefix matching
(must be a subset of the `searchableAttributes` index setting).

This setting is useful on attributes that contain string that should not be matched as a prefix
(for example a product SKU).

#### disableExactOnAttributes

- scope: `settings`
- type: search
- default: `[]`

List of attributes on which you want to disable computation of the `exact` ranking criterion
(must be a subset of the `searchableAttributes` index setting).

#### exactOnSingleWordQuery

- scope: `settings` `search`
- type: string
- default: `attribute`

Controls how the `exact` ranking criterion is computed when the query contains only one word.

The following values are allowed:

* `none`: the `exact` ranking criterion is ignored on single word queries;
* `word`: the `exact` ranking criterion is set to 1 if the query word is found in the record.
  The query word must be at least 3 characters long and must not be a stop word in any supported language.
* `attribute` (default): the `exact` ranking criterion is set to 1 if the query string exactly matches an entire attribute value.
  For example, if you search for the TV show "V", you want it to match the query "V" *before* all popular TV shows starting with the letter V.

#### alternativesAsExact

- scope: `setting` `search`
- type: array of strings
- default: `["ignorePlurals", "singleWordSynonym"]`

List of alternatives that should be considered an exact match by the `exact` ranking criterion.

The following values are allowed:

* `ignorePlurals`: alternative words added by the [ignorePlurals](#ignoreplurals) feature;
* `singleWordSynonym`: single-word synonyms (example: "NY" = "NYC");
* `multiWordsSynonym`: multiple-words synonyms (example: "NY" = "New York").

## Performance

#### numericAttributesForFiltering

- scope: `settings`
- type: array of strings
- default: all numeric attributes
- formerly known as: `numericAttributesToIndex`

All numerical attributes are automatically indexed as numerical filters
(allowing filtering operations like `<` and `<=`).
If you don't need filtering on some of your numerical attributes,
you can specify this list to speed up the indexing.

**Note:** If you only need to filter on a numeric value with the operator `=` or `!=`,
you can speed up the indexing by specifying the attribute with `equalOnly(AttributeName)`.
The other operators will be disabled.

#### allowCompressionOfIntegerArray

- scope: `settings`
- type: boolean
- default: `false`

Enables compression of large integer arrays.

In data-intensive use-cases, we recommended enabling this feature to reach a better compression ratio on arrays
exclusively containing integers (as is typical of lists of user IDs or ACLs).

**Note:** When enabled, integer arrays may be reordered.

## Advanced

#### attributeForDistinct

- scope: `settings`
- type: string
- default: `null`

Name of the de-duplication attribute for the [distinct](#distinct) feature.

#### distinct

- scope: `settings` `search`
- type: integer \| boolean
- default: `0`

Controls de-duplication of results.

A non-zero value enables de-duplication; a zero value disables it.
Booleans are also accepted (though not recommended): false is treated as 0, and true is treated as 1.

**Note:** De-duplication requires a **de-duplication attribute** to be configured via the [attributeForDistinct](#attributefordistinct) index setting.
If not configured, `distinct` will be accepted at query time but silently ignored.

This feature is similar to the SQL `distinct` keyword. When set to N (where N > 0), at most N hits will be returned
with the same value for the de-duplication attribute.

**Example:** If the de-duplication attribute is `show_name` and `distinct` is set to 1, then if several hits have the
same value for `show_name`, only the most relevant one is kept (with respect to the ranking formula); the others are removed.

To get a full understanding of how `distinct` works,
you can have a look at our [Guides](https://www.algolia.com/doc/guides/search/distinct).

#### getRankingInfo

- scope: `search`
- type: boolean
- default: `false`

Enables detailed ranking information.

When true, each hit in the response contains an additional `_rankingInfo` object containing the following fields:

<!-- TODO: Factorize this list with the Search Response Format section. -->

- `nbTypos` (integer): Number of typos encountered when matching the record. Corresponds to the `typos` ranking criterion in the ranking formula.

- `firstMatchedWord` (integer): Position of the most important matched attribute in the attributes to index list. Corresponds to the `attribute` ranking criterion in the ranking formula.

- `proximityDistance` (integer): When the query contains more than one word, the sum of the distances between matched words. Corresponds to the `proximity` criterion in the ranking formula.

- `userScore` (integer): Custom ranking for the object, expressed as a single numerical value. Conceptually, it's what the position of the object would be in the list of all objects sorted by custom ranking. Corresponds to the `custom` criterion in the ranking formula.

- `geoDistance` (integer): Distance between the geo location in the search query and the best matching geo location in the record, divided by the geo precision.

- `geoPrecision` (integer): Precision used when computed the geo distance, in meters. All distances will be floored to a multiple of this precision.

- `nbExactWords` (integer): Number of exactly matched words. If `alternativeAsExact` is set, it may include plurals and/or synonyms.

- `words` (integer): Number of matched words, including prefixes and typos.

- `filters` (integer): *This field is reserved for advanced usage.* It will be zero in most cases.

In addition, the response contains the following additional top-level fields:

- `serverUsed` (string): Actual host name of the server that processed the request. (Our DNS supports automatic failover and load balancing, so this may differ from the host name used in the request.)

- `parsedQuery` (string): The query string that will be searched, after normalization. Normalization includes removing stop words (if [removeStopWords](#removestopwords) is enabled), and transforming portions of the query string into phrase queries (see [advancedSyntax](#advancedsyntax)).

- `timeoutCounts` (boolean): Whether a timeout was hit when computing the facet counts. When `true`, the counts will be interpolated (i.e. approximate). See also `exhaustiveFacetsCount`.

- `timeoutHits` (boolean): Whether a timeout was hit when retrieving the hits. When true, some results may be missing.

#### numericFilters

- scope: `search`
- type: array of strings
- default: `[]`

Filter hits based on values of numeric attributes.

**Note:** The [filters](#filters) parameter provides an easier to use, SQL-like syntax.
We recommend using it instead of `numericFilters`.

Each string represents a filter on a numeric attribute. Two forms are supported:

- **Comparison**: `${attributeName} ${operator} ${operand}` matches all objects where the specified numeric attribute satisfies the numeric condition expressed by the operator and the operand. The operand must be a numeric value. Supported operators are `<`, `<=`, `=`, `!=`, `>=` and `>`, with the same semantics as in virtually all programming languages.
Example: `inStock > 0`.

- **Range**: `${attributeName}:${lowerBound} TO ${upperBound}` matches all objects where the specified numeric
attribute is within the range [`${lowerBound}`, `${upperBound}`] (inclusive on both ends).
Example: `price: 0 TO 1000`.

If you specify multiple filters, they are interpreted as a conjunction (AND). If you want to use a disjunction (OR),
use a nested array.

Examples:

- `["inStock > 0", "price < 1000"]` translates as `inStock > 0 AND price < 1000`
- `[["inStock > 0", "deliveryDate < 1441755506"], "price < 1000"]` translates as `(inStock > 0 OR deliveryDate < 1441755506) AND price < 1000`

#### tagFilters

- scope: `search`
- type: array of strings
- default: `[]`

Filter hits by tags.

Tags must be contained in a top-level `_tags` attribute of your objects at indexing time.

**Note:** Tags are essentially an implicit facet on the `_tags` attribute.
We therefore recommend that you use facets instead.
See [attributesForFaceting](#attributesforfaceting) and [facets](#facets).

**Note:** The [filters](#filters) parameter provides an easier to use, SQL-like syntax.
We recommend using it instead of `tagFilters`.

Each string represents a given tag value that must be matched.

If you specify multiple tags, they are interpreted as a conjunction (AND). If you want to use a disjunction (OR),
use a nested array.

Examples:

- `["Book", "Movie"]` translates as `Book AND Movie`
- `[["Book", "Movie"], "SciFi"]` translates as `(Book OR Movie) AND SciFi"`

Negation is supported by prefixing the tag value with a minus sign (`-`, a.k.a. dash).
For example: `["tag1", "-tag2"]` translates as `tag1 AND NOT tag2`.

#### analytics

- scope: `search`
- type: boolean
- default: `true`

Whether the current query will be taken into account in the Analytics.

#### analyticsTags

- scope: `search`
- type: array of strings
- default: `[]`

List of tags to apply to the query in the Analytics.

Tags can be used in the Analytics to filter searches.

#### synonyms

- scope: `search`
- type: boolean
- default: `true`

Whether to take into account synonyms defined for the targeted index.

#### replaceSynonymsInHighlight

- scope: `settings` `search`
- type: boolean
- default: `true`

Whether to replace words matched via synonym expansion by the matched synonym in highlight and snippet results.

When true, highlighting and snippeting will use words from the query rather than the original words from the objects.
When false, highlighting and snippeting will always display the original words from the objects.

**Note:** Multiple words can be replaced by a one-word synonym, but not the other way round.
For example, if "NYC" and "New York City" are synonyms, searching for "NYC" will replace "New York City" with "NYC"
in highlights and snippets, but searching for "New York City" will *not* replace "NYC" with "New York City" in
highlights and snippets.

#### placeholders

- scope: `settings`
- type: object of array of words
- default: `{}`

This is an advanced use-case to define a token substitutable by a list of words
without having the original token searchable.

It is defined by a hash associating placeholders to lists of substitutable words.

For example, `"placeholders": { "<streetnumber>": ["1", "2", "3", ..., "9999"]}`
would allow it to be able to match all street numbers. We use the `< >` tag syntax
to define placeholders in an attribute.

For example:

* Push a record with the placeholder:
`{ "name" : "Apple Store", "address" : "&lt;streetnumber&gt; Opera street, Paris" }`.
* Configure the placeholder in your index settings:
`"placeholders": { "<streetnumber>" : ["1", "2", "3", "4", "5", ... ], ... }`.

#### altCorrections

- scope: `settings`
- type: array of objects
- default: `[]`

Specify alternative corrections that you want to consider.

Each alternative correction is described by an object containing three attributes:

* `word` (string): The word to correct.
* `correction` (string): The corrected word.
* `nbTypos` (integer): The number of typos (1 or 2) that will be considered for the ranking algorithm (1 typo is better than 2 typos).

For example:

```
"altCorrections": [
  { "word" : "foot", "correction": "feet", "nbTypos": 1 },
  { "word": "feet", "correction": "foot", "nbTypos": 1 }
]
```

#### minProximity

- scope: `settings` `search`
- type: integer
- default: `1`

Precision of the `proximity` ranking criterion.

By default, the minimum (and best) proximity value between two matching words is 1.

Setting it to 2 (respectively N) would allow 1 (respectively N-1) additional word(s) to be found between two matching words without degrading the proximity ranking value.

**Example:** considering the query *"javascript framework"*, if you set `minProximity` to 2,
two records containing respectively *"JavaScript framework"* and *"JavaScript charting framework"*
will get the same proximity score, even if the latter contains an additional word between the two matching words.

**Note:** The maximum value for `minProximity` is 7. Any higher value will **disable** the `proximity` criterion in the ranking formula.

#### responseFields

- scope: `settings` `search`
- type: array of strings
- default: `*` (all fields)

Choose which fields the response will contain. Applies to search and browse queries.

By default, all fields are returned. If this parameter is specified, only the fields explicitly
listed will be returned, unless `*` is used, in which case all fields are returned.
Specifying an empty list or unknown field names is an error.

This parameter is mainly intended to limit the response size.
For example, in complex queries, echoing of request parameters in the response's `params` field can be undesirable.

List of fields that can be filtered out:

- `aroundLatLng`
- `automaticRadius`
- `exhaustiveFacetsCount`
- `facets`
- `facets_stats`
- `hits`
- `hitsPerPage`
- `index`
- `length`
- `nbHits`
- `nbPages`
- `offset`
- `page`
- `params`
- `processingTimeMS`
- `query`
- `queryAfterRemoval`

List of fields that *cannot* be filtered out:

- `message`
- `warning`
- `cursor`
- `serverUsed`
- `timeoutCounts` (deprecated, please use `exhaustiveFacetsCount` instead)
- `timeoutHits` (deprecated, please use `exhaustiveFacetsCount` instead)
- `parsedQuery`
- all fields triggered by [getRankingInfo](#getrankinginfo)


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


