Change Log
==========

## 4.8.1 (2017-04-18)

### Miscellaneous changes

- [offline] Better error reporting when building offline indices


## 4.8 (2017-04-03)

### New features

- **Compatibility with Swift 3.1.** (#294) *Note: Swift 3.1 being source-compatible with Swift 3.0, version 4.7 was already compatible out of the box, but this one eliminates a few compile-time warnings.*
- Support **new search parameters** in the `Query` class:
    - `disableExactOnAttributes` (#369)
    - `offset` & `length` (#369)
    - `percentileComputation` (#365)
    - `restrictHighlightAndSnippetArrays` (#366)
- Properties of the query classes (`AbstractQuery` and its derivates) are now **KVO-observable**
- Add an option to choose a **custom queue** for completion handlers (#334). By default, the main queue is used.

### Other changes

- The `userAgents` property (managing the `User-Agent` HTTP header) is now a static property of the `Client` class. This should ease its use by other libraries, most notably [InstantSearch Core](https://github.com/algolia/instantsearch-core-swift).
- [offline] Unify `Index` and `OfflineIndex` under a new `Searchable` protocol. This makes possible generic algorithms that work with any kind of index (`MirroredIndex` being a subclass of `Index` already).
- Shorter README. The complete reference is now only on <https://www.algolia.com/doc/api-client/swift/>.


## 4.7 (2017-02-08)

### New features

- Support `facetingAfterDistinct` query parameter
- Support `maxFacetHits` parameter when searching for facet values
- [offline] Support offline search for facet values

### Bug fixes

- (#285) Fix race condition when searching while activating mirrored mode

### Other changes

- Update URL of generated reference documentation


## 4.6.1 (2017-01-10)

### Bug fixes

- [offline] Fix reachability handling in `onlineOnly` request strategy


## 4.6 (2016-12-28)

### New features

- [offline] Support manual building of local indices (`MirroredIndex` and `OfflineIndex`)
- [offline] Support fallback logic when getting individual objects

### Bug fixes

- (#168) Use network reachability to decide whether to perform online requests
- [offline] Fix race condition in instantiation of local index


## 4.5 (2016-12-07)

**Note:** *This new version brings a major improvement in the request retry logic (fallback mechanism used when one or more API hosts are down or unreachable). For that reason, an upgrade to this or a later version is strongly recommended for all users of this API Client.*

### New features

- (#158) Support the `responseFields` query parameter

### Bug fixes

- (#157) New retry logic: stateful host statuses. This should help largely minimize the impact of DNS resolution failures or other long-lasting network problems. Note that the timeout for statuses can be controlled via the `AbstractClient.hostStatusTimeout` property.

### Other changes

- Support more than one polygon in the `insidePolygon` query parameter. **Warning:** This breaks backward-compatibility for this specific parameter.


## 4.4 (2016-11-18)

### New features

- (#140) Support searching for facet values (`Index.searchForFacetValues(...)`)
- New method `AbstractQuery.clear()` to remove all parameters

### Other changes

- Open the `Query` class (along with some of its methods) to allow subclassing in other libraries
- Make available as a static utility the method to build a query string from a dictionary of parameters (`AbstractQuery.build(build(parameters:)`)


## 4.3 (2016-11-10)

### New features

- (#152) Add support for [Algolia Places](https://community.algolia.com/places/)


## 4.2 (2016-11-02)

### New features

- Add support for a list of languages in the `ignorePlurals` query parameter. **Warning:** This breaks backward-compatibility for this specific parameter.

### Bug fixes

- (#144) Fix compilation warning with Xcode 8.1

### Other changes

- (Objective-C bridging) Switch back to only one `Query` class. **Note:** This change is backward-compatible at the source level, provided that:
    - Objective-C code did not reference the `BaseQuery` type explicitly
    - Swift code did not reference the `_objc_Query` type explicitly


## 4.1 (2016-10-03)

### New features

- Support the `createIfNotExists` parameter in partial updates
- [offline] Offline-only indices

### Bug fixes

- (#134) Use new format version when retrieving index settings
- Fix asynchronous dispatch of some completion handlers (were called outside the main thread)

### Other changes

- Rename `attributesToIndex` to `searchableAttributes`


## 4.0.1 (2016-09-15)

- Fix `NSCopying` support in Objective-C
- [Offline mode] Upgrade to Offline Core 1.0


## 4.0 (2016-09-14)

This is a new major version, bringing incompatible changes, most of them due to **Swift 3 support**.

**Note:** You can find a detailed change log and migration instructions in the [Migration guide to version 4.x](https://github.com/algolia/algoliasearch-client-swift/wiki/Migration-guide-to-version-4.x).

**Warning:** This version requires Swift 3; it will not compile with Swift 2.x.

**Warning:** Cocoapods support for Swift 3 requires Cocoapods 1.1.0.rc.2 or later.

### Swift 3 support

- Adapt to the new Foundation API
- Follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines):
    - Argument labels:
        - Omit the first argument when the function name contains a complement (e.g. `addObject`) or when the purpose is obvious (`search`: with a query)
        - Label the first argument when the purpose is not obvious and not contained in the method name (e.g. `batch(operations:)`)
        - Label all completion handlers explicitly. This is the convention adopted by the system's libraries (e.g. `URLSession.dataTask(with:completionHandler:)`. Since the completion handler is likely to be a closure, the block can be moved out of the call site anyway, so the label is only required when passing a function/block reference.
    - Method names:
        - `browse` is now overloaded: `browse(query:)` and `browse(from:)`.
    - Rename enum members to lower camel case
    - Rename constants to lower camel case (except notification names)
- Better Objective-C mappings
    - Adjust method names when necessary for a better fit with this language
    - Objective-C specific types are no longer visible in Swift (well, technically, they still are, but you have to look harder...)
    - No underscore-suffixed properties any longer
- Better typing
    - Use `Error` instead of `NSError` in completion handlers
        - Use dedicated error types
    - Use `@discardableResult` for methods returning `Operation`
    - Use `Notification.Name` for notifications
- Prevent subclassing by *not* adopting the `open` access modifier

### Other breaking changes

- (Swift only) Better typing of complex properties through enums
- Rename `Index.indexName` to `Index.name`.
- Refactor index search cache handling into two properties to enable/disable (`searchCacheEnabled`) it and set the expiration delay (`searchCacheExpiringTimeInterval`), and one method to clear it (`clearSearchCache()`)
- Rename "slaves" to "replicas"

### Other improvements

- Improve cancellation of `Index.waitTask()`
- Add tests for Objective-C bridging (online flavor only)
- Make timeouts configurable
- `Index` instances are now shared across a `Client`


## 3.7 (2016-09-07)

- (#118) Add support for **watchOS**
- (#120) Add an `Index.getObjects()` method with attributes to retrieve
- Improve bandwidth usage of the "delete by query" helper
- Fix memory leaks
- Generate reference documentation for both the online and offline flavors

## 3.6 (2016-08-09)

- Add explicit support for **tvOS** in the Cocoapods pod spec. (In fact, tvOS has been supported for a while in our code, but somehow never made it to the pod spec.) *Note: not supported by the offline mode.*
- Add support for HTML documentation generation via [Jazzy](https://github.com/realm/jazzy)
- Fix behavior of the `exhaustiveFacetsCount` response field when using disjunctive faceting
- Migrate the `User-Agent` HTTP header to a new, more parseable format; now also includes the operating system's version.
- Change value of `ErrorDomain` constant. *Note: not a breaking change unless you relied on the value itself.*
- Update documentation

### Offline mode

- Expose last successful sync date (property `MirroredIndex.lastSuccessfulSyncDate`)


## 3.5 (2016-07-29)

- New `multipleQueries()` method at index level
- Fix cancellation of requests: in some edge cases, the completion handler could be called after cancellation
- Fix potential crash when cancelling requests (unsafe assertions were made)

The following changes are for the offline mode only:

- New offline fallback strategy. **Warning: breaking change:** preventive search no longer supported.
- Offline requests now also work for disjunctive faceting
- The `searchMirror()` method has been renamed to `searchOffline()`, for better consistency with the newly introduced `searchOnline()` method.
- Improve detection of non-existent indices


## 3.4 (2016-07-25)

- New `Client.isAlive()` method (`/1/isalive` endpoint)
- Completion handler is now mandatory for multiple queries. **Warning: breaking change**
- (#88) Fix passing of `strategy` parameter in multiple queries (should be POST instead of GET)
- (#103) Fix URL encoding of path components (e.g. spaces in index names)
- Add test case for TCP connection dropping


## 3.3 (2016-06-29)

- (#77) Support a list of languages as a value for the `removeStopWords` query parameter. **Warning:** The type of the
  corresponding property had to be degraded from `Bool?` to `AnyObject?`; as a consequence, the getter suffers from an
  incompatible change (but not the setter).
- (#79) Support `aroundRadius=all` in query parameters
- (#76) Support the `exactOnSingleWordQuery` query parameter
- (#76) Support the `alternativesAsExact` query parameter
- (#74) Support Swift 2.3
- (#75) Fix iTunes Connect submission issue when using Carthage: minimum iOS version is now 8.0
- Update documentation


## 3.2.1 (2016-05-27)

- Fix OS X support in CocoaPods


## 3.2 (2016-05-26)

- Support iOS 7.0
    - **Warning:** Because CocoaPods uses dynamic frameworks and Swift is not supported in dynamic frameworks on iOS 7,
    iOS 7 support is not possible through CocoaPods.
    - **Warning:** Due to unavailability of simulators earlier than iOS 8.1 in Xcode 7.3, iOS 7 remains **untested**.
- README updated
- [Test] Add test case for DNS time-out

### Experimental features

- Offline mode. *Note: requires the Algolia Search Offline Core library.* **Warning: beta version.**


## 3.1 (2016-05-09)

- Add tvOS target
- Restore [Carthage](https://github.com/Carthage/Carthage) support
- Add typed properties for query parameters `filters` and `numericFilters`
- Shuffle host array at init time, for better load balancing
- Update documentation
- Fix unit tests: remove broken "keep alive" test case


## 3.0 (2016-04-13)

This major version brings new features and bug fixes. In addition, a lot of refactoring has been performed to achieve
better Objective-C bridging, better maintainability, as well as to align the Swift client with the other Algolia API
clients.

As a consequence, the public interface has changed in an incompatible way. Please refer to our
[Migration Guide](https://github.com/algolia/algoliasearch-client-swift/wiki/Migration-guide-to-version-3.x) for
detailed instructions.

### New features

- Allow arbitrary query parameters to be specified: the `Query` class provides low-level, untyped accessors in addition
  to the higher-level, typed properties.
- Allow arbitrary HTTP headers to be specified (`Client.headers`)
- Asynchronous requests are cancellable: asynchronous methods return an `NSOperation` instance, making it possible to
  call `cancel()` on it.
- Timeout settings now user-configurable
- Batch operation support
- Multiple queries `strategy` parameter support
- Disjunctive faceting helper
- Delete by query helper
- Browse iterator helper (`BrowseIterator`)

### Changes

- Asynchronous methods completion block argument renamed to `completionHandler` for better consistency with the
  system libraries (in particular `NSURLSession`)
- Align `Query` class parameters with the [REST API](https://www.algolia.com/doc/rest)
- Remove operations requiring an admin API key. (The admin key should *never* be used on the client side.)
- Browse methods now only low-level. (For high-level iteration, use the `BrowseIterator` helper; see above.)
- Remove accessors to deprecated HTTP headers

### Fixes

- **Full Objective-C bridging**: all features are now available from Objective-C.
- More consistent error handling
- Fix percent-escaping of query parameters in URLs
- Fix Swift 2.2 deprecation warnings
- HTTP headers can now be changed during the client's lifetime

### Misc. improvements

- Minimize public interface
- Update documentation
- Add test cases


## 2.2.1 (2016-02-05)

* Added support of snippet ellipsis query parameter

## 2.2.0 (2015-12-11)

* Added support for optional tag filters

## 2.1.0 (2015-10-20)

* Added support of multiple bounding box for geo-search
* Added support of polygon for geo-search
* Added support of automatic radius computation for geo-search
* Added support of disableTypoToleranceOnAttributes
* Fix `NSJSONSerialization` crashes

## 2.0.0 (2015-09-22)

* Upgrade to Swift 2

## 1.4.2 (2015-08-18)

* Fix crash when requesting with a poor connection

## 1.4.1 (2015-07-10)

* Add `analyticsTags`

## 1.4.0 (2015-07-06)

* Objective-C support
* New `browseFrom` methods
* Add search cache (disabled by default)

## 1.3.0 (2015-06-30)

* Added support of grouping (`distinct=3` for example keep the 3 best hits for a distinct key)

## 1.2.3 (2015-06-21)

* add copy constructor for `Query`

## 1.2.2 (2015-06-16)

* new browse method that takes a `Query` object

## 1.2.1 (2015-06-09)

* rename `fullTextQuery` to `query`

## 1.2.0 (2015-06-08)

* new retry logic
* add new parameter on the Query: `setMinProximity` & `setHighlightingTags`
* add new method on the Query: `resetLocationParameters`
