<!--NO_HTML-->

# Algolia Search API Client for Swift

**&lt;Welcome Objective-C developers&gt;**

In July 2015, we released a **new version** of our Swift client, able to work with Swift and Objective-C. As of version 3 (April 2016), Swift has become the reference implementation for both Swift and Objective-C projects.

If you were using our Objective-C client, read the [migration guide from Objective-C](https://github.com/algolia/algoliasearch-client-swift/wiki/Migration-guide-from-Objective-C-to-Swift-API-Client). The [Objective-C API Client](https://github.com/algolia/algoliasearch-client-objc) is no longer under active development. It is still supported for bug fixes, but will not receive new features.

**&lt;/Welcome Objective-C developers&gt;**

If you were using **version 2.x** of our Swift client, read the [migration guide to version 3.x](https://github.com/algolia/algoliasearch-client-swift/wiki/Migration-guide-to-version-3.x).





[Algolia Search](https://www.algolia.com) is a hosted full-text, numerical, and faceted search engine capable of delivering realtime results from the first keystroke.


Our Swift client lets you easily use the [Algolia Search API](https://www.algolia.com/doc/rest) from your iOS, macOS and tvOS applications. It wraps the [Algolia Search REST API](https://www.algolia.com/doc/rest).



[![Build Status](https://travis-ci.org/algolia/algoliasearch-client-swift.svg?branch=master)](https://travis-ci.org/algolia/algoliasearch-client-swift)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods](https://img.shields.io/cocoapods/v/AlgoliaSearch-Client-Swift.svg)]()
[![CocoaPods](https://img.shields.io/cocoapods/l/AlgoliaSearch-Client-Swift.svg)]()
[![](https://img.shields.io/badge/OS%20X-10.9%2B-lightgrey.svg)]()
[![](https://img.shields.io/badge/iOS-7.0%2B-lightgrey.svg)]()







## Table of Contents

**Getting Started**

1. [Getting started](#getting-started)
1. [Quick Start](#quick-start)
1. [Guides & Tutorials](#guides--tutorials)


**Commands Reference**

Getting started

1. [Install](#install)
1. [Init index](#init-index---initindex)

Search

1. [Search in an index](#search-in-an-index---search)
1. [Find by IDs](#find-by-ids---getobjects)
1. [Search cache](#search-cache)

Indexing

1. [Add objects](#add-objects---addobjects)
1. [Update objects](#update-objects---saveobjects)
1. [Partial update](#partial-update---partialupdateobjects)
1. [Delete objects](#delete-objects---deleteobjects)

Settings

1. [Get settings](#get-settings---getsettings)
1. [Set settings](#set-settings---setsettings)

Manage Indices

1. [List indices](#list-indices---listindexes)
1. [Delete index](#delete-index---deleteindex)
1. [Clear index](#clear-index---clearindex)
1. [Copy index](#copy-index---copyindex)
1. [Move index](#move-index---moveindex)




Advanced

1. [Custom batch](#custom-batch---batch)
1. [Wait for operations](#wait-for-operations---waittask)
1. [Multiple queries](#multiple-queries---multiplequeries)
1. [Delete by query](#delete-by-query---deletebyquery)
1. [Backup / Export an index](#backup--export-an-index---browse)



## Guides & Tutorials

Check our [online guides](https://www.algolia.com/doc):

 * [Data Formatting](https://www.algolia.com/doc/indexing/formatting-your-data)
 * [Import and Synchronize data](https://www.algolia.com/doc/indexing/import-synchronize-data/swift)
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









<!--/NO_HTML-->




## Getting Started

### Install




1. Add a dependency on AlgoliaSearch-Client-Swift:
    - CocoaPods: add `pod 'AlgoliaSearch-Client-Swift', '~> 3.0'` to your `Podfile`.
    - Carthage: add `github "algolia/algoliasearch-client-swift"` to your `Cartfile`.
2. Add `import AlgoliaSearch` to your source files.


### Init index - `initIndex`

To initialize the client, you need your **Application ID** and **API Key**. You can find both of them on [your Algolia account](https://www.algolia.com/api-keys).

```swift
let client = Client(appID: "YourApplicationID", apiKey: "YourAPIKey")
```



### Quick Start



In 30 seconds, this quick start tutorial will show you how to index and search objects.

Without any prior configuration, you can start indexing [500 contacts](https://github.com/algolia/algoliasearch-client-csharp/blob/master/contacts.json) in the ```contacts``` index using the following code:

```swift
// Load content file
let jsonPath = NSBundle.mainBundle().pathForResource("contacts", ofType: "json")
let jsonData = NSData(contentsOfFile: jsonPath)
let dict = try! NSJSONSerialization.JSONObjectWithData(jsonData!, options: [])

// Load all objects of json file in an index named "contacts"
let index = client.getIndex("contacts")
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
let settings = ["attributesToIndex": customRanking]
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









## Search

### Search in an index - `search`



To perform a search, you only need to initialize the index and perform a call to the search function.

The search query allows only to retrieve 1000 hits. If you need to retrieve more than 1000 hits (e.g. for SEO), you can use [Backup / Retrieve all index content](#backup--export-an-index).

```swift
let index = client.getIndex("contacts")
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

### Search Response Format

#### Sample

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

#### Fields

- `hits` (array): The hits returned by the search, sorted according to the ranking formula.

    Hits are made of the JSON objects that you stored in the index; therefore, they are mostly schema-less. However, Algolia does enrich them with a few additional fields:

    - `_highlightResult` (object, optional): Highlighted attributes. *Note: Only returned when [`attributesToHighlight`](#attributestohighlight) is non-empty.*

        - `${attribute_name}` (object): Highlighting for one attribute.

            - `value` (string): Markup text with occurrences highlighted. The tags used for highlighting are specified via [`highlightPreTag`](#highlightpretag) and [`highlightPostTag`](#highlightposttag).

            - `matchLevel` (string, enum) = {`none` | `partial` | `full`}: Indicates how well the attribute matched the search query.

            - `matchedWords` (array): List of words *from the query* that matched the object.

            - `fullyHighlighted` (boolean): Whether the entire attribute value is highlighted.

    - `_snippetResult` (object, optional): Snippeted attributes. *Note: Only returned when [`attributesToSnippet`](#attributestosnippet) is non-empty.*

        - `${attribute_name}` (object): Snippeting for the corresponding attribute.

            - `value` (string): Markup text with occurrences highlighted and optional ellipsis indicators. The tags used for highlighting are specified via [`highlightPreTag`](#highlightpretag) and [`highlightPostTag`](#highlightposttag). The text used to indicate ellipsis is specified via [`snippetEllipsisText`](#snippetellipsistext).

            - `matchLevel` (string, enum) = {`none` | `partial` | `full`}: Indicates how well the attribute matched the search query.

    - `_rankingInfo` (object, optional): Ranking information. *Note: Only returned when [`getRankingInfo`](#getrankinginfo) is `true`.*

        - `nbTypos` (integer): Number of typos encountered when matching the record. Corresponds to the `typos` ranking criterion in the ranking formula.

        - `firstMatchedWord` (integer): Position of the most important matched attribute in the attributes to index list. Corresponds to the `attribute` ranking criterion in the ranking formula.

        - `proximityDistance` (integer): When the query contains more than one word, the sum of the distances between matched words. Corresponds to the `proximity` criterion in the ranking formula.

        - `userScore` (integer): Custom ranking for the object, expressed as a single numerical value. Conceptually, it's what the position of the object would be in the list of all objects sorted by custom ranking. Corresponds to the `custom` criterion in the ranking formula.

        - `geoDistance` (integer): Distance between the geo location in the search query and the best matching geo location in the record, divided by the geo precision.

        - `geoPrecision` (integer): Precision used when computed the geo distance, in meters. All distances will be floored to a multiple of this precision.

        - `nbExactWords` (integer): Number of exactly matched words. If `alternativeAsExact` is set, it may include plurals and/or synonyms.

        - `words` (integer): Number of matched words, including prefixes and typos.

        - `filters` (integer): *This field is reserved for advanced usage.* It will be zero in most cases.

    - `_distinctSeqID` (integer): *Note: Only returned when [`distinct`](#distinct) is non-zero.* When two consecutive results have the same value for the attribute used for "distinct", this field is used to distinguish between them.

- `nbHits` (integer): Number of hits that the search query matched.

- `page` (integer): Index of the current page (zero-based). See the [`page`](#page) search parameter. *Note: Not returned if you use `offset`/`length` for pagination.*

- `hitsPerPage` (integer): Maximum number of hits returned per page. See the [`hitsPerPage`](#hitsperpage) search parameter. *Note: Not returned if you use `offset`/`length` for pagination.*

- `nbPages` (integer): Number of pages corresponding to the number of hits. Basically, `ceil(nbHits / hitsPerPage)`. *Note: Not returned if you use `offset`/`length` for pagination.*

- `processingTimeMS` (integer): Time that the server took to process the request, in milliseconds. *Note: This does not include network time.*

- `query` (string): An echo of the query text. See the [`query`](#query) search parameter.

- `queryAfterRemoval` (string, optional): *Note: Only returned when [`removeWordsIfNoResults`](#removewordsifnoresults) is set.* A markup text indicating which parts of the original query have been removed in order to retrieve a non-empty result set. The removed parts are surrounded by `<em>` tags.

- `params` (string, URL-encoded): An echo of all search parameters.

- `message` (string, optional): Used to return warnings about the query.

- `aroundLatLng` (string, optional): *Note: Only returned when [`aroundLatLngViaIP`](#aroundlatlngviaip) is set.* The computed geo location. **Warning: for legacy reasons, this parameter is a string and not an object.** Format: `${lat},${lng}`, where the latitude and longitude are expressed as decimal floating point numbers.

- `automaticRadius` (integer, optional): *Note: Only returned for geo queries without an explicitly specified radius (see `aroundRadius`).* The automatically computed radius. **Warning: for legacy reasons, this parameter is a string and not an integer.**

When [`getRankingInfo`](#getrankinginfo) is set to `true`, the following additional fields are returned:

- `serverUsed` (string): Actual host name of the server that processed the request. (Our DNS supports automatic failover and load balancing, so this may differ from the host name used in the request.)

- `parsedQuery` (string): The query string that will be searched, after normalization. Normalization includes removing stop words (if [removeStopWords](#removestopwords) is enabled), and transforming portions of the query string into phrase queries (see [advancedSyntax](#advancedsyntax)).

- `timeoutCounts` (boolean): Whether a timeout was hit when computing the facet counts. When `true`, the counts will be interpolated (i.e. approximate). See also `exhaustiveFacetsCount`.

- `timeoutHits` (boolean): Whether a timeout was hit when retrieving the hits. When true, some results may be missing.

... and ranking information is also added to each of the hits (see above).

When [`facets`](#facets) is non-empty, the following additional fields are returned:

- `facets` (object): Maps each facet name to the corresponding facet counts:

    - `${facet_name}` (object): Facet counts for the corresponding facet name:

        - `${facet_value}` (integer): Count for this facet value.

- `facets_stats` (object, optional): *Note: Only returned when at least one of the returned facets contains numerical values.* Statistics for numerical facets:

    - `${facet_name}` (object): The statistics for a given facet:

        - `min` (integer | float): The minimum value in the result set.

        - `max` (integer | float): The maximum value in the result set.

        - `avg` (integer | float): The average facet value in the result set.

        - `sum` (integer | float): The sum of all values in the result set.

- `exhaustiveFacetsCount` (boolean): Whether the counts are exhaustive (`true`) or approximate (`false`). *Note: When using [`distinct`](#distinct), the facet counts cannot be exhaustive.*


### Search Parameters

<!--PARAMETERS_LINK-->
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

- [queryType](#querytype) `settings`, `search`
- [removeWordsIfNoResults](#removewordsifnoresults) `settings`, `search`
- [advancedSyntax](#advancedsyntax) `settings`, `search`
- [optionalWords](#optionalwords) `settings`, `search`
- [removeStopWords](#removestopwords) `settings`, `search`
- [disableExactOnAttributes](#disableexactonattributes) `settings`, `search`
- [exactOnSingleWordQuery](#exactonsinglewordquery) `settings`, `search`
- [alternativesAsExact](#alternativesasexact) `settings`, `search`

**Advanced**

- [distinct](#distinct) `settings`, `search`
- [getRankingInfo](#getrankinginfo) `search`
- [numericFilters (deprecated)](#numericfilters-deprecated) `search`
- [tagFilters (deprecated)](#tagfilters-deprecated) `search`
- [facetFilters (deprecated)](#facetfilters-deprecated) `search`
- [analytics](#analytics) `search`
- [analyticsTags](#analyticstags) `search`
- [synonyms](#synonyms) `search`
- [replaceSynonymsInHighlight](#replacesynonymsinhighlight) `search`, `settings`
- [minProximity](#minproximity) `search`, `settings`

<!--/PARAMETERS_LINK-->

### Multiple queries - `multipleQueries`

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

#### Response

The resulting JSON contains the following fields:

- `results` (array): The results for each request, in the order they were submitted. The contents are the same as in [Search in an index](#search-in-an-index---search).

    Each result also includes the following additional fields:

    - `index` (string): The name of the targeted index.

    - `processed` (boolean, optional): *Note: Only returned when `strategy` is `stopIfEnoughmatches`.* Whether the query was processed.



### Find by IDs - `getObjects`

You can easily retrieve an object using its `objectID` and optionally specify a comma separated list of attributes you want:

```swift
// Retrieves all attributes
index.getObject("myID", completionHandler: { (content, error) -> Void in
	if error == nil {
		print("Object: \(content)")
	}
})
// Retrieves only the firstname attribute
index.getObject("myID", attributesToRetrieve: ["firstname"], completionHandler: { (content, error) -> Void in
	if error == nil {
		print("Object: \(content)")
	}
})
```

You can also retrieve a set of objects:

```swift
index.getObjects(["myID1", "myID2"], completionHandler: { (content, error) -> {
	// do something
})
```



### Search cache

You can easily cache the results of the search queries by enabling the search cache.
The results will be cached during a defined amount of time (default: 2 min).
There is no pre-caching mechanism but you can simulate it by making a preemptive search query.

By default, the cache is disabled.

```swift
// Enable the search cache with default settings.
index.enableSearchCache()
```

Or:

```swift
// Enable the search cache with a TTL of 5 minutes.
index.enableSearchCache(expiringTimeInterval: 300)
```




## Indexing

*Note: In most use cases, updating indices is better done from your back-end. Methods in this section are documented for the sake of completeness.*


### Add objects - `addObjects`

Each entry in an index has a unique identifier called `objectID`. There are two ways to add an entry to the index:

 1. Using automatic `objectID` assignment. You will be able to access it in the answer.
 2. Supplying your own `objectID`.

You don't need to explicitly create an index, it will be automatically created the first time you add an object.
Objects are schema less so you don't need any configuration to start indexing. If you wish to configure things, the settings section provides details about advanced settings.

Example with automatic `objectID` assignment:

```swift
let newObject = ["firstname": "Jimmie", "lastname": "Barninger"]
index.addObject(newObject, completionHandler: { (content, error) -> Void in
	if error == nil {
		if let objectID = content!["objectID"] as? String {
			print("Object ID: \(objectID)")
		}
	}
})
```

Example with manual `objectID` assignment:

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


### Update objects - `saveObjects`

You have three options when updating an existing object:

 1. Replace all its attributes.
 2. Replace only some attributes.
 3. Apply an operation to some attributes.

Example on how to replace all attributes of an existing object:

```swift
let newObject = [
	"firstname": "Jimmie",
	"lastname": "Barninger",
	"city": "New York",
	"objectID": "myID"
]
index.saveObject(newObject)
```

### Partial update - `partialUpdateObjects`

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
index.partialUpdateObject(partialObject, objectID: "myID")
```

Example to add a tag:

```swift
let operation = [
	"value": "MyTag",
	"_operation": "Add"
]
let partialObject = ["_tags": operation]
index.partialUpdateObject(partialObject, objectID: "myID")
```

Example to remove a tag:

```swift
let operation = [
	"value": "MyTag",
	"_operation": "Remove"
]
let partialObject = ["_tags": operation]
index.partialUpdateObject(partialObject, objectID: "myID")
```

Example to add a tag if it doesn't exist:

```swift
let operation = [
	"value": "MyTag",
	"_operation": "AddUnique"
]
let partialObject = ["_tags": operation]
index.partialUpdateObject(partialObject, objectID: "myID")
```

Example to increment a numeric value:

```swift
let operation = [
	"value": 42,
	"_operation": "Increment"
]
let partialObject = ["price": operation]
index.partialUpdateObject(partialObject, objectID: "myID")
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
index.partialUpdateObject(partialObject, objectID: "myID")
```

Note: Here we are decrementing the value by `42`. To decrement just by one, put
`value:1`.


### Delete objects - `deleteObjects`

You can delete an object using its `objectID`:

```swift
index.deleteObject("myID")
```

### Delete by query - `deleteByQuery`

You can delete all objects matching a single query with the following code. Internally, the API client performs the query, deletes all matching hits, and waits until the deletions have been applied.


Take your precautions when using this method. Calling it with an empty query will result in cleaning the index of all its records.

```swift
let query: Query = /* [...] */
index.deleteByQuery(query)
```

### Wait for operations - `waitTask`

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
	self.index.waitTask(taskID, completionHandler: { (content, error) -> Void in
		if error == nil {
			print("New object is indexed!")
		}
	})
})
```

If you want to ensure multiple objects have been indexed, you only need to check
the biggest `taskID`.


## Settings

*Note: In most use cases, updating indices is better done from your back-end. Methods in this section are documented for the sake of completeness.*


### Get settings - `getSettings`

You can retrieve settings:

```swift
index.getSettings(completionHandler: { (content, error) -> Void in
	if error == nil 
		print("Settings: \(content!)")
	}
})
```

### Set settings - `setSettings`

```swift
let customRanking = ["desc(followers)", "asc(name)"]
let settings = ["customRanking": customRanking]
index.setSettings(settings)
```

**Warning**

Performance wise, it's better to do a `setSettings` before pushing the data

#### Slave settings

You can forward all settings updates to the slaves of an index by using the `forwardToSlaves` option:

```swift
let settings = ["attributesToRetrieve": "name", "birthdate"]
index.setSettings(settings, forwardToSlaves: true, completionHandler: { (content, error) -> Void in
    // [...]
})
```



### Index settings parameters

<!--PARAMETERS_LINK-->

Here is the list of parameters you can use with the set settings method (`indexing` [scope](#scope))


Parameters that can be overridden at search time also have the `search` [scope](#scope)

**Attributes**

- [attributesToIndex](#attributestoindex) `settings`
- [attributesForFaceting](#attributesforfaceting) `settings`
- [attributesToRetrieve](#attributestoretrieve) `settings`, `search`
- [unretrievableAttributes](#unretrievableattributes) `settings`

**Ranking**

- [ranking](#ranking) `settings`
- [customRanking](#customranking) `settings`
- [slaves](#slaves) `settings`

**Filtering / Faceting**

- [maxValuesPerFacet](#maxvaluesperfacet) `settings`, `search`

**Highlighting / Snippeting**

- [attributesToHighlight](#attributestohighlight) `settings`, `search`
- [attributesToSnippet](#attributestosnippet) `settings`, `search`
- [highlightPreTag](#highlightpretag) `settings`, `search`
- [highlightPostTag](#highlightposttag) `settings`, `search`
- [snippetEllipsisText](#snippetellipsistext) `settings`, `search`

**Pagination**

- [hitsPerPage](#hitsperpage) `settings`, `search`

**Typos**

- [minWordSizefor1Typo](#minwordsizefor1typo) `settings`, `search`
- [minWordSizefor2Typos](#minwordsizefor2typos) `settings`, `search`
- [typoTolerance](#typotolerance) `settings`, `search`
- [allowTyposOnNumericTokens](#allowtyposonnumerictokens) `settings`, `search`
- [ignorePlurals](#ignoreplurals) `settings`, `search`
- [disableTypoToleranceOnAttributes](#disabletypotoleranceonattributes) `settings`, `search`
- [separatorsToIndex](#separatorstoindex) `settings`

**Query Strategy**

- [queryType](#querytype) `settings`, `search`
- [removeWordsIfNoResults](#removewordsifnoresults) `settings`, `search`
- [advancedSyntax](#advancedsyntax) `settings`, `search`
- [optionalWords](#optionalwords) `settings`, `search`
- [removeStopWords](#removestopwords) `settings`, `search`
- [disablePrefixOnAttributes](#disableprefixonattributes) `settings`
- [disableExactOnAttributes](#disableexactonattributes) `settings`, `search`
- [exactOnSingleWordQuery](#exactonsinglewordquery) `settings`, `search`
- [alternativesAsExact](#alternativesasexact) `settings`, `search`

**Advanced**

- [attributeForDistinct](#attributefordistinct) `settings`
- [distinct](#distinct) `settings`, `search`
- [numericAttributesToIndex](#numericattributestoindex) `settings`
- [allowCompressionOfIntegerArray](#allowcompressionofintegerarray) `settings`
- [altCorrections](#altcorrections) `settings`
- [placeholders](#placeholders) `settings`

<!--/PARAMETERS_LINK-->


## Parameters

### Overview

#### Scope

Each parameter in this page has a scope. Depending on the scope, you can use the parameter within the `setSettings`
and/or the `search` method

They are three scopes:

- `settings`: The setting can only be used in the `setSettings` method
- `search`: The setting can only be used in the `search` method
- `settings` `search`: The setting can be used in the `setSettings` method and be override in the`search` method


#### Parameters List

**Search**

- [query](#query) `search`

**Attributes**

- [attributesToIndex](#attributestoindex) `settings`
- [attributesForFaceting](#attributesforfaceting) `settings`
- [unretrievableAttributes](#unretrievableattributes) `settings`
- [attributesToRetrieve](#attributestoretrieve) `settings`, `search`
- [restrictSearchableAttributes](#restrictsearchableattributes) `search`

**Ranking**

- [ranking](#ranking) `settings`
- [customRanking](#customranking) `settings`
- [slaves](#slaves) `settings`

**Filtering / Faceting**

- [filters](#filters) `search`
- [facets](#facets) `search`
- [maxValuesPerFacet](#maxvaluesperfacet) `settings`, `search`

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

- [queryType](#querytype) `settings`, `search`
- [removeWordsIfNoResults](#removewordsifnoresults) `settings`, `search`
- [advancedSyntax](#advancedsyntax) `settings`, `search`
- [optionalWords](#optionalwords) `settings`, `search`
- [removeStopWords](#removestopwords) `settings`, `search`
- [disablePrefixOnAttributes](#disableprefixonattributes) `settings`
- [disableExactOnAttributes](#disableexactonattributes) `settings`, `search`
- [exactOnSingleWordQuery](#exactonsinglewordquery) `settings`, `search`
- [alternativesAsExact](#alternativesasexact) `settings`, `search`

**Advanced**

- [attributeForDistinct](#attributefordistinct) `settings`
- [distinct](#distinct) `settings`, `search`
- [getRankingInfo](#getrankinginfo) `search`
- [numericAttributesToIndex](#numericattributestoindex) `settings`
- [allowCompressionOfIntegerArray](#allowcompressionofintegerarray) `settings`
- [numericFilters (deprecated)](#numericfilters-deprecated) `search`
- [tagFilters (deprecated)](#tagfilters-deprecated) `search`
- [facetFilters (deprecated)](#facetfilters-deprecated) `search`
- [analytics](#analytics) `search`
- [analyticsTags](#analyticstags) `search`
- [synonyms](#synonyms) `search`
- [replaceSynonymsInHighlight](#replacesynonymsinhighlight) `search`, `settings`
- [placeholders](#placeholders) `settings`
- [altCorrections](#altcorrections) `settings`
- [minProximity](#minproximity) `search`, `settings`

### Search

#### query

- scope: `search`
- type: `string`
- default: `""`


The instant search query string, used to set the string you want to search in your index. If no query parameter is set, the textual search will match with all the objects.

### Attributes

#### attributesToIndex

- scope: `settings`
- type: `array of strings`
- default: `*`


The list of attributes you want index (i.e. to make searchable).

If set to null, all textual and numerical attributes of your objects are indexed.
Make sure you updated this setting to get optimal results.

This parameter has two important uses:

1. **Limit the attributes to index.** For example, if you store the URL of a picture, you want to store it and be able to retrieve it, but you probably don't want to search in the URL.

2. **Control part of the ranking.** The contents of the `attributesToIndex` parameter impacts ranking in two complementary ways:

    First, the order in which attributes are listed defines their ranking priority: matches in attributes at the beginning of the list will be considered more important than matches in attributes further down the list. To assign the same priority to several attributes, pass them within the same string, separated by commas. For example, by specifying `["title,"alternative_title", "text"]`, `title` and `alternative_title` will have the same priority, but a higher priority than `text`.

    Then, within the same attribute, matches near the beginning of the text will be considered more important than matches near the end. You can disable this behavior by wrapping your attribute name inside an `unordered()` modifier. For example, `["title", "unordered(text)"]` will consider all positions inside the `text` attribute as equal, but positions inside the `title` attribute will still matter.

**Note:** To get a full description of how the ranking works, you can have a look at our [Ranking guide](https://www.algolia.com/doc/guides/relevance/ranking).


#### attributesForFaceting

- scope: `settings`
- type: `array of strings`
- default: `null`


The list of attributes you want to use for faceting.
All strings within these attributes will be extracted and added as facets.
If set to `null`, no attribute is used for faceting.


#### unretrievableAttributes

- scope: `settings`
- type: `array of strings`
- default: `null`


The list of attributes that cannot be retrieved at query time.
This feature allows you to have attributes that are used for indexing
and/or ranking but cannot be retrieved.

**Warning**: For testing purposes, this setting is ignored when you're using the **admin** API key.

#### attributesToRetrieve

- scope: `settings`, `search`
- type: `array of strings`
- default: `*`


A string that contains the list of attributes you want to retrieve in order to minimize the size of the JSON answer.

Attributes are separated with a comma (for example `"name,address"`).
You can also use a string array encoding (for example `["name","address"]` ).
By default, all attributes are retrieved.
You can also use `*` to retrieve all values when an **attributesToRetrieve** setting is specified for your index.

**Note:** `objectID` is always retrieved, even when not specified.


#### restrictSearchableAttributes

- scope: `search`
- type: `array of strings`
- default: `attributesToIndex`


List of attributes you want to use for textual search (must be a subset of the `attributesToIndex` index setting).
Attributes are separated with a comma such as `"name,address"`.
You can also use JSON string array encoding such as `encodeURIComponent("[\"name\",\"address\"]")`.
By default, all attributes specified in the `attributesToIndex` settings are used to search.


### Ranking

#### ranking

- scope: `settings`
- type: `array of strings`
- default: `['typo', 'geo', 'words', 'filters', 'proximity', 'attribute', 'exact', 'custom']`


Controls the way results are sorted.

We have nine available criterion:

* `typo`: Sort according to number of typos.
* `geo`: Sort according to decreasing distance when performing a geo location based search.
* `words`: Sort according to the number of query words matched by decreasing order. This parameter is useful when you use the `optionalWords` query parameter to have results with the most matched words first.
* `proximity`: Sort according to the proximity of the query words in hits.
* `attribute`: Sort according to the order of attributes defined by attributesToIndex.
* `exact`:
  * If the user query contains one word: sort objects having an attribute that is exactly the query word before others. For example, if you search for the TV show "V", you want to find it with the "V" query and avoid getting all popular TV shows starting by the letter V before it.
  * If the user query contains multiple words: sort according to the number of words that matched exactly (not as a prefix).
* `custom`: Sort according to a user defined formula set in the `customRanking` attribute.
* `asc(attributeName)`: Sort according to a numeric attribute using ascending order. `attributeName` can be the name of any numeric attribute in your records (integer, double or boolean).
* `desc(attributeName)`: Sort according to a numeric attribute using descending order. `attributeName` can be the name of any numeric attribute in your records (integer, double or boolean).

To get a full description of how the Ranking works,
you can have a look at our [Ranking guide](https://www.algolia.com/doc/guides/relevance/ranking).

#### customRanking

- scope: `settings`
- type: `array of strings`
- default: `[]`


Lets you specify part of the ranking.

The syntax of this condition is an array of strings containing attributes
prefixed by the asc (ascending order) or desc (descending order) operator.

For example, `"customRanking" => ["desc(population)", "asc(name)"]`.

To get a full description of how the Custom Ranking works,
you can have a look at our [Ranking guide](https://www.algolia.com/doc/guides/relevance/ranking).

#### slaves

- scope: `settings`
- type: `array of strings`
- default: `[]`


The list of indices on which you want to replicate all write operations.

In order to get response times in milliseconds, we pre-compute part of the ranking during indexing.

If you want to use different ranking configurations depending of the use case,
you need to create one index per ranking configuration.

This option enables you to perform write operations only on this index and automatically
update slave indices with the same operations.

### Filtering / Faceting

#### filters

- scope: `search`
- type: `string`
- default: `""`


Filter the query with numeric, facet or/and tag filters.

The syntax is a SQL like syntax, you can use the OR and AND keywords.
The syntax for the underlying numeric, facet and tag filters is the same than in the other filters:

`available=1 AND (category:Book OR NOT category:Ebook) AND _tags:public`
`date: 1441745506 TO 1441755506 AND inStock > 0 AND author:"John Doe"`

If no attribute name is specified,
the filter applies to `_tags`.

For example: `public OR user_42` will translate to `_tags:public OR _tags:user_42`.

The list of keywords is:

* `OR`: create a disjunctive filter between two filters.
* `AND`: create a conjunctive filter between two filters.
* `TO`: used to specify a range for a numeric filter.
* `NOT`: used to negate a filter. The syntax with the `-` isn’t allowed.

**Note:** To specify a value with spaces or with a value equal to a keyword, it's possible to add quotes.

**Warnings:**

* Like for the other filters (for performance reasons), it's not possible to have `FILTER1 OR (FILTER2 AND FILTER3)`.
* It is not possible to mix different categories of filters inside an OR like: `num=3 OR tag1 OR facet:value`.
* It is not possible to negate a group; only individual filters can be negated:  `NOT(FILTER1 OR (FILTER2))` is not allowed.


#### facets

- scope: `search`
- type: `string`
- default: `""`


You can use [facets](#facets) to retrieve only a part of your attributes declared in
**[attributesForFaceting](#attributesforfaceting)** attributes.
It will not filter your results, if you want to filter results you should use [filters](#filters).

For each of the declared attributes, you'll be able to retrieve a list of the most relevant facet values,
and their associated count for the current query.

**Example**

If you have defined in your **[attributesForFaceting](#attributesforfaceting)**:

```
["category", "author", "nb_views", "nb_downloads"]
```

... but, for the current search, you want to retrieve facet values only for `category` and `author`, then you can specify:

```
["category", "author"]
```

**Warnings**

- When using [facets](#facets) in a search query, only attributes that have been added in **attributesForFaceting** index setting can be used in this parameter.
You can also use `*` to perform faceting on all attributes specified in `attributesForFaceting`.
If the number of results is important, the count can be approximate,
the attribute `exhaustiveFacetsCount` in the response is true when the count is exact.

#### maxValuesPerFacet

- scope: `settings`, `search`
- type: `integer`
- default: `""`


Limit the number of facet values returned for each facet.

For example, `maxValuesPerFacet=10` will retrieve a maximum of 10 values per facet.

**Warnings**

- The engine has a hard limit on the `maxValuesPerFacet` of `1000`. Any value above that will be interpreted by the engine as being `1000`.

### Highlighting / Snippeting

#### attributesToHighlight

- scope: `settings`, `search`
- type: `array of strings`
- default: `null`


Default list of attributes to highlight.
If set to null, all indexed attributes are highlighted.

A string that contains the list of attributes you want to highlight according to the query.
Attributes are separated by commas.
You can also use a string array encoding (for example `["name","address"]`).
If an attribute has no match for the query, the raw value is returned.
By default, all indexed attributes are highlighted (as long as they are strings).
You can use `*` if you want to highlight all attributes.

A matchLevel is returned for each highlighted attribute and can contain:

* `full`: If all the query terms were found in the attribute.
* `partial`: If only some of the query terms were found.
* `none`: If none of the query terms were found.

#### attributesToSnippet

- scope: `settings`, `search`
- type: `array of strings`
- default: `null`


Default list of attributes to snippet alongside the number of words to return (syntax is `attributeName:nbWords`).
If set to null, no snippet is computed.

#### highlightPreTag

- scope: `settings`, `search`
- type: `string`
- default: `<em>`


Specify the string that is inserted before the highlighted parts in the query result (defaults to `<em>`).



#### highlightPostTag

- scope: `settings`, `search`
- type: `string`
- default: `</em>`


Specify the string that is inserted after the highlighted parts in the query result (defaults to `</em>`).



#### snippetEllipsisText

- scope: `settings`, `search`
- type: `string`
- default: `…`


String used as an ellipsis indicator when a snippet is truncated.

**Note:** Defaults to an empty string for all accounts created before 10/2/2016, and to `…` (U+2026) for accounts created after that date.

#### restrictHighlightAndSnippetArrays

- scope: `settings`, `search`
- type: `boolean`
- default: `false`


If set to true, restrict arrays in highlights and snippets to items that matched the query at least partially else return all array items in highlights and snippets.

### Pagination

#### page

- scope: `search`
- type: `integer`
- default: `0`


Pagination parameter used to select the page to retrieve.

**Warning:** Page is zero based. Thus, to retrieve the 10th page, you need to set `page=9`.

#### hitsPerPage

- scope: `settings`, `search`
- type: `integer`
- default: `20`


Pagination parameter used to select the number of hits per page.

#### offset

- scope: `search`
- type: `integer`
- default: `null`


Offset of the first hit to return (zero-based).

**Warning:** In most cases, `page`/`hitsPerPage` is the recommended method for pagination; `offset`/`length` is reserved for advanced use.

#### length

- scope: `search`
- type: `integer`
- default: `null`


Number of hits to return.

**Warning:** In most cases, `page`/`hitsPerPage` is the recommended method for pagination; `offset`/`length` is reserved for advanced use.

### Typos

#### minWordSizefor1Typo

- scope: `settings`, `search`
- type: `integer`
- default: `4`


The minimum number of characters needed to accept one typo.

#### minWordSizefor2Typos

- scope: `settings`, `search`
- type: `integer`
- default: `8`


The minimum number of characters needed to accept two typos.

#### typoTolerance

- scope: `settings`, `search`
- type: `boolean`
- default: `true`


This option allows you to control the number of typos allowed in the result set:

* `true`: The typo tolerance is enabled and all matching hits are retrieved (default behavior).
* `false`: The typo tolerance is disabled. All results with typos will be hidden.
* `min`: Only keep results with the minimum number of typos. For example, if one result matches without typos, then all results with typos will be hidden.
* `strict`: Hits matching with 2 typos are not retrieved if there are some matching without typos.


#### allowTyposOnNumericTokens

- scope: `settings`, `search`
- type: `boolean`
- default: `true`


If set to false, disables typo tolerance on numeric tokens (numbers).

#### ignorePlurals

- scope: `settings`, `search`
- type: `boolean`
- default: `false`


If set to true, plural won't be considered as a typo. For example, car and cars, or foot and feet will be considered as equivalent. Defaults to false.

#### disableTypoToleranceOnAttributes

- scope: `settings`, `search`
- type: `string`
- default: `""`


List of attributes on which you want to disable typo tolerance
(must be a subset of the `attributesToIndex` index setting).

Attributes are separated with a comma such as `"name,address"`.
You can also use JSON string array encoding such as `encodeURIComponent("[\"name\",\"address\"]")`.

#### separatorsToIndex

- scope: `settings`
- type: `string`
- default: `""`


Specify the separators (punctuation characters) to index.

By default, separators are not indexed.

**Example:** Use `+#` to be able to search for "Google+" or "C#".



### Geo-Search

Geo search requires that you provide at least one geo location in each record at indexing time, under the `_geoloc` attribute. Each location must be an object with two numeric `lat` and `lng` attributes. You may specify either one location:

```
{
  "_geoloc": {
    "lat": 48.853409,
    "lng": 2.348800
  }
}
```

... or an array of locations:

```
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




#### aroundLatLng

- scope: `search`
- type: `string`
- default: ``


Search for entries around a given location (specified as two floats separated by a comma).

For example, `aroundLatLng=47.316669,5.016670`.

- By default the maximum distance is automatically guessed based on the density of the area
but you can specify it manually in meters with the **aroundRadius** parameter.
The precision for ranking can be set with **aroundPrecision** parameter.
- If you set aroundPrecision=100, the distances will be considered by ranges of 100m.
- For example all distances 0 and 100m will be considered as identical for the "geo" ranking parameter.

When `aroundRadius` is not set, the radius is computed automatically using the density of the area; you can retrieve the computed value in the `automaticRadius` attribute of the response.
You can also use the `minimumAroundRadius` query parameter to specify a minimum radius in meters for the automatic computation of `aroundRadius`.





#### aroundLatLngViaIP

- scope: `search`
- type: `string`
- default: `false`


Search for entries around a given latitude/longitude automatically computed from user IP address.

To enable it, use `aroundLatLngViaIP=true`.

You can specify the maximum distance in meters with the `aroundRadius` parameter
and the precision for ranking with `aroundPrecision`.

For example:
- if you set aroundPrecision=100,
two objects that are in the range 0-99m
will be considered as identical in the ranking for the "geo" ranking parameter (same for 100-199, 200-299, ... ranges).



#### aroundRadius

- scope: `search`
- type: `integer`, `"all"`
- default: `null`


Control the radius associated with a geo search. Defined in meters.

If not set, the radius is computed automatically using the density of the area. You can retrieve the computed radius in the `automaticRadius` attribute of the response. You can also specify a minimum value for the automatic radius by using the `minimumAroundRadius` query parameter. You can specify `aroundRadius=all` if you want to compute the geo distance without filtering in a geo area; this option will be faster than specifying a big integer value.

#### aroundPrecision

- scope: `search`
- type: `integer`
- default: `null`


Control the precision of a geo search. Defined in meters. For example, if you set `aroundPrecision=100`, two objects that are in the range 0-99m will be considered as identical in the ranking for the `geo` ranking parameter (same for 100-199, 200-299, … ranges).

#### minimumAroundRadius

- scope: `search`
- type: `integer`
- default: `null`


Define the minimum radius used for a geo search when `aroundRadius` is not set. The radius is computed automatically using the density of the area. You can retrieve the computed radius in the `automaticRadius` attribute of the answer.

#### insideBoundingBox

- scope: `search`
- type: `string`
- default: `null`


Search entries inside a given area defined by the two extreme points of a rectangle
(defined by 4 floats: p1Lat,p1Lng,p2Lat,p2Lng).
For example:
- `insideBoundingBox=47.3165,4.9665,47.3424,5.0201`

You can use several bounding boxes (OR) by passing more than 4 values.
For example: instead of having 4 values you can pass 8 to search inside the UNION of two bounding boxes.

#### insidePolygon

- scope: `search`
- type: `string`
- default: ``


Search entries inside a given area defined by a set of points
(defined by a minimum of 6 floats: p1Lat,p1Lng,p2Lat,p2Lng,p3Lat,p3Long).

For example:
`InsidePolygon=47.3165,4.9665,47.3424,5.0201,47.32,4.98`).


### Query Strategy

#### queryType

- scope: `settings`, `search`
- type: `enum`
- default: `'prefixLast'`


Selects how the query words are interpreted. It can be one of the following values:
* `prefixAll`:
All query words are interpreted as prefixes. This option is not recommended.
* `prefixLast`:
Only the last word is interpreted as a prefix (default behavior).
* `prefixNone`:
No query word is interpreted as a prefix. This option is not recommended.

#### removeWordsIfNoResults

- scope: `settings`, `search`
- type: `string`
- default: `'none'`


This option is used to select a strategy in order to avoid having an empty result page.
There are four different options:

- `lastWords`:
When a query does not return any results, the last word will be added as optional.
The process is repeated with n-1 word, n-2 word, ... until there are results.
- `firstWords`:
When a query does not return any results, the first word will be added as optional.
The process is repeated with second word, third word, ... until there are results.
- `allOptional`:
When a query does not return any results, a second trial will be made with all words as optional.
This is equivalent to transforming the AND operand between query terms to an OR operand.
- `none`:
No specific processing is done when a query does not return any results (default behavior).


#### advancedSyntax

- scope: `settings`, `search`
- type: `boolean`
- default: `false`


Enables the advanced query syntax.

This syntax allow to do two things:

* **Phrase query**: A phrase query defines a particular sequence of terms. A phrase query is built by Algolia's query parser for words surrounded by `"`. For example, `"search engine"` will retrieve records having `search` next to `engine` only. Typo tolerance is _disabled_ on phrase queries.
* **Prohibit operator**: The prohibit operator excludes records that contain the term after the `-` symbol. For example, `search -engine` will retrieve records containing `search` but not `engine`.


#### optionalWords

- scope: `settings`, `search`
- type: `array of strings`
- default: `[]`


A string that contains the comma separated list of words that should be considered as optional when found in the query.

#### removeStopWords

- scope: `settings`, `search`
- type: `boolean`, `array of strings`
- default: `false`


Remove stop words from the query **before** executing it. It can be:

- a **boolean**: enable or disable stop words for all 41 supported languages; or
- a **list of language ISO codes** (as a comma-separated string) for which stop words should be enabled.

In most use-cases, **we don’t recommend enabling this option**.

List of 41 supported languages with their associated iso code: Arabic=`ar`, Armenian=`hy`, Basque=`eu`, Bengali=`bn`, Brazilian=`pt-br`, Bulgarian=`bg`, Catalan=`ca`, Chinese=`zh`, Czech=`cs`, Danish=`da`, Dutch=`nl`, English=`en`, Finnish=`fi`, French=`fr`, Galician=`gl`, German=`de`, Greek=`el`, Hindi=`hi`, Hungarian=`hu`, Indonesian=`id`, Irish=`ga`, Italian=`it`, Japanese=`ja`, Korean=`ko`, Kurdish=`ku`, Latvian=`lv`, Lithuanian=`lt`, Marathi=`mr`, Norwegian=`no`, Persian (Farsi)=`fa`, Polish=`pl`, Portugese=`pt`, Romanian=`ro`, Russian=`ru`, Slovak=`sk`, Spanish=`es`, Swedish=`sv`, Thai=`th`, Turkish=`tr`, Ukranian=`uk`, Urdu=`ur`.

Stop words removal is applied on query words that are not interpreted as a prefix. The behavior depends of the `queryType` parameter:

* `queryType=prefixLast` means the last query word is a prefix and it won’t be considered for stop words removal
* `queryType=prefixNone` means no query word are prefix, stop words removal will be applied on all query words
* `queryType=prefixAll` means all query terms are prefix, stop words won’t be removed

This parameter is useful when you have a query in natural language like “what is a record?”.
In this case, before executing the query, we will remove “what”, “is” and “a” in order to just search for “record”.
This removal will remove false positive because of stop words, especially when combined with optional words.
For most use cases, it is better to not use this feature as people search by keywords on search engines.




#### disablePrefixOnAttributes

- scope: `settings`
- type: `array of strings`
- default: `[]`


List of attributes on which you want to disable prefix matching
(must be a subset of the `attributesToIndex` index setting).

This setting is useful on attributes that contain string that should not be matched as a prefix
(for example a product SKU).


#### disableExactOnAttributes

- scope: `settings`, `search`
- type: `array of strings`
- default: `[]`


List of attributes on which you want to disable the computation of `exact` criteria
(must be a subset of the `attributesToIndex` index setting).

#### exactOnSingleWordQuery

- scope: `settings`, `search`
- type: `string`
- default: `attribute`


This parameter control how the `exact` ranking criterion is computed when the query contains one word. There are three different values:

* `none`: no exact on single word query
* `word`: exact set to 1 if the query word is found in the record. The query word needs to have at least 3 chars and not be part of our stop words dictionary
* `attribute` (default): exact set to 1 if there is an attribute containing a string equals to the query

#### alternativesAsExact

- scope: `settings`, `search`
- type: `string`
- default: `['ignorePlurals', 'singleWordSynonym']`


Specify the list of approximation that should be considered as an exact match in the ranking formula:

* `ignorePlurals`: alternative words added by the ignorePlurals feature
* `singleWordSynonym`: single-word synonym (For example "NY" = "NYC")
* `multiWordsSynonym`: multiple-words synonym (For example "NY" = "New York")

### Advanced

#### attributeForDistinct

- scope: `settings`
- type: `string`
- default: `null`


The name of the attribute used for the `Distinct` feature.

This feature is similar to the SQL "distinct" keyword.
When enabled in queries with the `distinct=1` parameter,
all hits containing a duplicate value for this attribute are removed from the results.

For example, if the chosen attribute is `show_name` and several hits have the same value for `show_name`,
then only the first one is kept and the others are removed from the results.

To get a full understanding of how `Distinct` works,
you can have a look at our [guide on distinct](https://www.algolia.com/doc/search/distinct).

#### distinct

- scope: `settings`, `search`
- type: `integer`
- default: `0`


If set to 1,
enables the distinct feature, disabled by default, if the `attributeForDistinct` index setting is set.

This feature is similar to the SQL "distinct" keyword.
When enabled in a query with the `distinct=1` parameter,
all hits containing a duplicate value for the attributeForDistinct attribute are removed from results.

For example, if the chosen attribute is `show_name` and several hits have the same value for `show_name`,
then only the best one is kept and the others are removed.

To get a full understanding of how `Distinct` works,
you can have a look at our [guide on distinct](https://www.algolia.com/doc/search/distinct).


#### getRankingInfo

- scope: `search`
- type: `boolean`
- default: `false`


If set to true,
the result hits will contain ranking information in the **_rankingInfo** attribute.

#### numericAttributesToIndex

- scope: `settings`
- type: `array of strings`
- default: ``


All numerical attributes are automatically indexed as numerical filters
(allowing filtering operations like `<` and `<=`).
If you don't need filtering on some of your numerical attributes,
you can specify this list to speed up the indexing.

If you only need to filter on a numeric value with the `=` operator,
you can speed up the indexing by specifying the attribute with `equalOnly(AttributeName)`.
The other operators will be disabled.

#### allowCompressionOfIntegerArray

- scope: `settings`
- type: `boolean`
- default: `false`


Allows compression of big integer arrays.

In data-intensive use-cases,
we recommended enabling this feature and then storing the list of user IDs or rights as an integer array.
When enabled, the integer array is reordered to reach a better compression ratio.

#### numericFilters (deprecated)

- scope: `search`
- type: `array of strings`
- default: `[]`


*This parameter is deprecated. Please use [filters](#filters) instead.*

A string that contains the comma separated list of numeric filters you want to apply.
The filter syntax is `attributeName` followed by `operand` followed by `value`.
Supported operands are `<`, `<=`, `=`, `>` and `>=`.

You can easily perform range queries via the `:` operator.
This is equivalent to combining a `>=` and `<=` operand.

For example, `numericFilters=price:10 to 1000`.

You can also mix OR and AND operators.
The OR operator is defined with a parenthesis syntax.

For example, `(code=1 AND (price:[0-100] OR price:[1000-2000]))`
translates to `encodeURIComponent("code=1,(price:0 to 100,price:1000 to 2000)")`.

You can also use a string array encoding (for example `numericFilters: ["price>100","price<1000"]`).

#### tagFilters (deprecated)

- scope: `search`
- type: `string`
- default: `""`


*This parameter is deprecated. Please use [filters](#filters) instead.*

Filter the query by a set of tags.

You can AND tags by separating them with commas.
To OR tags, you must add parentheses.

For example, `tagFilters=tag1,(tag2,tag3)` means *tag1 AND (tag2 OR tag3)*.

You can also use a string array encoding.

For example, `tagFilters: ["tag1",["tag2","tag3"]]` means *tag1 AND (tag2 OR tag3)*.

Negations are supported via the `-` operator, prefixing the value.

For example: `tagFilters=tag1,-tag2`.

At indexing, tags should be added in the **_tags** attribute of objects.

For example `{"_tags":["tag1","tag2"]}`.

#### facetFilters (deprecated)

- scope: `search`
- type: `string`
- default: `""`


*This parameter is deprecated. Please use [filters](#filters) instead.*

Filter the query with a list of facets. Facets are separated by commas and is encoded as `attributeName:value`.
To OR facets, you must add parentheses.

For example: `facetFilters=(category:Book,category:Movie),author:John%20Doe`.

You can also use a string array encoding.

For example, `[["category:Book","category:Movie"],"author:John%20Doe"]`.

#### analytics

- scope: `search`
- type: `boolean`
- default: `true`


If set to false, this query will not be taken into account in the analytics feature.

#### analyticsTags

- scope: `search`
- type: `array of strings`
- default: `null`


If set, tag your query with the specified identifiers. Tags can then be used in the Analytics to analyze a subset of searches only.

#### synonyms

- scope: `search`
- type: `boolean`
- default: `true`


If set to `false`, the search will not use the synonyms defined for the targeted index.

#### replaceSynonymsInHighlight

- scope: `search`, `settings`
- type: `boolean`
- default: `true`


If set to `false`, words matched via synonym expansion will not be replaced by the matched synonym in the highlighted result.

#### placeholders

- scope: `settings`
- type: `hash of array of words`
- default: ``


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
- type: `array of objects`
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

- scope: `search`, `settings`
- type: `integer`
- default: `1`


Configure the precision of the `proximity` ranking criterion. By default, the minimum (and best) proximity value distance between 2 matching words is 1. Setting it to 2 (or 3) would allow 1 (or 2) words to be found between the matching words without degrading the proximity ranking value.

Considering the query *“javascript framework”*, if you set `minProximity=2`, the records *“JavaScript framework”* and *“JavaScript charting framework”* will get the same proximity score, even if the second contains a word between the two matching words.

**Note:** the maximum `minProximity` that can be set is 7. Any higher value will disable the `proximity` criterion from the ranking formula.


## Manage Indices

*Note: In most use cases, updating indices is better done from your back-end. Methods in this section are documented for the sake of completeness.*


### Create an index

To create an index, you need to perform any indexing operation like:
- set settings
- add object

### List indices - `listIndexes`

You can list all your indices along with their associated information (number of entries, disk size, etc.) with the `` method:

```swift
client.listIndexes(completionHandler: { (content, error) -> Void in
	if error == nil {
		print("Indexes: \(content!)")
	}
})
```









## Advanced

### Custom batch - `batch`

You may want to perform multiple operations with one API call to reduce latency.
We expose four methods to perform batch operations:

* Add objects - `addObjects`: Add an array of objects using automatic `objectID` assignment.
* Update objects - `saveObjects`: Add or update an array of objects that contains an `objectID` attribute.
* Delete objects - `deleteObjects`: Delete an array of objectIDs.
* Partial update - `partialUpdateObjects`: Partially update an array of objects that contain an `objectID` attribute (only specified attributes will be updated).

Example using automatic `objectID` assignment:

```swift
let obj1 = ["firstname": "Jimmie", "lastname": "Barninger"]
let obj2 = ["firstname": "Warren", "lastname": "Speach"]
index.addObjects([obj1, obj2], completionHandler: { (content, error) -> Void in
	if error == nil {
		print("Object IDs: \(content!)")
	}
})
```

Example with user defined `objectID` (add or update):

```swift
let obj1 = ["firstname": "Jimmie", "lastname": "Barninger", "objectID": "myID1"]
let obj2 = ["firstname": "Warren", "lastname": "Speach", "objectID": "myID2"]
index.saveObjects([obj1, obj2], completionHandler: { (content, error) -> Void in
	if error == nil {
		print("Object IDs: \(content!)")
	}
})
```

Example that deletes a set of records:

```swift
index.deleteObjects(["myID1", "myID2"])
```

Example that updates only the `firstname` attribute:

```swift
let obj1 = ["firstname": "Jimmie", "objectID": "myID1"]
let obj2 = ["firstname": "Warren", "objectID": "myID2"]
index.partialUpdateObjects([obj1, obj2], completionHandler: { (content, error) -> Void in
	if error == nil {
		print("Object IDs: \(content!)")
	}
})
```



If you have one index per user, you may want to perform a batch operations across severals indexes.
We expose a method to perform this type of batch:



The attribute **action** can have these values:

- addObject
- updateObject
- partialUpdateObject
- partialUpdateObjectNoCreate
- deleteObject

### Backup / Export an index - `browse`

The `search` method cannot return more than 1,000 results. If you need to
retrieve all the content of your index (for backup, SEO purposes or for running
a script on it), you should use the `browse` method instead. This method lets
you retrieve objects beyond the 1,000 limit.

This method is optimized for speed. To make it fast, distinct, typo-tolerance,
word proximity, geo distance and number of matched words are disabled. Results
are still returned ranked by attributes and custom ranking.


It will return a `cursor` alongside your data, that you can then use to retrieve
the next chunk of your records.

You can specify custom parameters (like `page` or `hitsPerPage`) on your first
`browse` call, and these parameters will then be included in the `cursor`. Note
that it is not possible to access records beyond the 1,000th on the first call.

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
index.browse(Query(), completionHandler: { (content, error) in
	if error != nil {
		return
	}
	// Handle content [...]
	// If there is more content...
	if let cursor = content!["cursor"] as? String {
		index.browseFrom(cursor, completionHandler: { (content, error) in
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



### REST API

We've developed API clients for the most common programming languages and platforms.
These clients are advanced wrappers on top of our REST API itself and have been made
in order to help you integrating the service within your apps:
for both indexing and search.

Everything that can be done using the REST API can be done using those clients.

The REST API lets your interact directly with Algolia platforms from anything that can send an HTTP request
[Go to the REST API doc](https://algolia.com/doc/rest)




