Change Log
==========

## 3.3 (TODO: Freeze date when released)

- (#77) Support a list of languages as a value for the `removeStopWords` query parameter. **Warning:** The type of the
  corresponding property had to be degraded from `Bool?` to `AnyObject?`; as a consequence, the getter suffers from an
  incompatible change (but not the setter).
- (#79) Support `aroundRadius=all` in query parameters.
- (#76) Support the `exactOnSingleWordQuery` query parameter
- (#76) Support the `alternativesAsExact` query parameter


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
