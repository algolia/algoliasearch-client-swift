Change Log
==========

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
