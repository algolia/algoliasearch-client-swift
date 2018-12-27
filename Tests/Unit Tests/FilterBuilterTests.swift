//
//  FilterBuilterTests.swift
//  AlgoliaSearch
//
//  Created by Guy Daher on 10/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

import InstantSearchClient
import XCTest

class FilterBuilderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }


    func testPlayground() {
        
        let filterBuilder = FilterBuilder()
        let filterFacet1 = FilterFacet(attribute: "category", value: "table")
        let filterFacet2 = FilterFacet(attribute: "category", value: "chair")
        let filterNumeric1 = FilterNumeric(attribute: "price", operator: .greaterThan, value: 10)
        let filterNumeric2 = FilterNumeric(attribute: "price", operator: .lessThan, value: 20)
        let filterTag1 = FilterTag(value: "Tom")
        let filterTag2 = FilterTag(value: "Hank")

        let groupFacets = OrFilterGroup<FilterFacet>(name: "filterFacets")
        let groupFacetsOtherInstance = OrFilterGroup<FilterFacet>(name: "filterFacets")
        let groupNumerics = AndFilterGroup(name: "filterNumerics")
        let groupTagsOr = OrFilterGroup<FilterTag>(name: "filterTags")
        let groupTagsAnd = AndFilterGroup(name: "filterTags")

        filterBuilder.add(filterFacet1, to: groupFacets)
        // Make sure that if we re-create a group instance, filters will stay in same group bracket
        filterBuilder.add(filterFacet2, to: groupFacetsOtherInstance)

        filterBuilder.add(filterNumeric1, to: groupNumerics)
        filterBuilder.add(filterNumeric2, to: groupNumerics)
         // Repeat once to see if the Set rejects same filter
        filterBuilder.add(filterNumeric2, to: groupNumerics)

        filterBuilder.addAll( [filterTag1, filterTag2], to: groupTagsOr)
        filterBuilder.add(filterTag1, to: groupTagsAnd)
        let expectedFilterBuilder = """
                                    ( "category":"chair" OR "category":"table" ) AND "price" < 20.0 AND "price" > 10.0 AND "_tags":"Tom" AND ( "_tags":"Hank" OR "_tags":"Tom" )
                                    """
        XCTAssertEqual(filterBuilder.build(), expectedFilterBuilder)
        
        XCTAssertTrue(filterBuilder.contains(filterFacet1))
        
        let missingFilter = FilterFacet(attribute: "bla", value: false)
        XCTAssertFalse(filterBuilder.contains(missingFilter))
        
        filterBuilder.remove(filterTag1, from: groupTagsAnd) // existing one
        filterBuilder.remove(filterTag1, from: groupTagsAnd) // remove one more time
        filterBuilder.remove(FilterTag(value: "unexisting"), from: groupTagsOr) // remove one that does not exist
        filterBuilder.remove(filterFacet1) // Remove in all groups

        let expectedFilterBuilder2 = """
                                    "category":"chair" AND "price" < 20.0 AND "price" > 10.0 AND ( "_tags":"Hank" OR "_tags":"Tom" )
                                    """
        XCTAssertEqual(filterBuilder.build(), expectedFilterBuilder2)

        filterBuilder.removeAll([filterNumeric1, filterNumeric2])

        let expectedFilterBuilder3 = """
                                    "category":"chair" AND ( "_tags":"Hank" OR "_tags":"Tom" )
                                    """
        XCTAssertEqual(filterBuilder.build(), expectedFilterBuilder3)
        
    }
    
    func testAdd() {
        
        let filterBuilder = FilterBuilder()
        
        let filterFacet1 = FilterFacet(attribute: Attribute("category"), value: "table")
        let filterFacet2 = FilterFacet(attribute: Attribute("category"), value: "chair")
        let filterNumeric1 = FilterNumeric(attribute: "price", operator: .greaterThan, value: 10)
        let filterNumeric2 = FilterNumeric(attribute: "price", operator: .lessThan, value: 20)
        let filterTag1 = FilterTag(value: "Tom")
        let filterTag2 = FilterTag(value: "Hank")
        
        let groupFacets = OrFilterGroup<FilterFacet>(name: "filterFacets")
        let groupFacetsOtherInstance = OrFilterGroup<FilterFacet>(name: "filterFacets")
        let groupNumerics = AndFilterGroup(name: "filterNumerics")
        let groupTagsOr = OrFilterGroup<FilterTag>(name: "filterTags")
        let groupTagsAnd = AndFilterGroup(name: "filterTags")
        
        filterBuilder.add(filterFacet1, to: groupFacets)
        // Make sure that if we re-create a group instance, filters will stay in same group bracket
        filterBuilder.add(filterFacet2, to: groupFacetsOtherInstance)
        
        filterBuilder.add(filterNumeric1, to: groupNumerics)
        filterBuilder.add(filterNumeric2, to: groupNumerics)
        // Repeat once to see if the Set rejects same filter
        filterBuilder.add(filterNumeric2, to: groupNumerics)
        
        filterBuilder.addAll([filterTag1, filterTag2], to: groupTagsOr)
        filterBuilder.add(filterTag1, to: groupTagsAnd)
        let expectedFilterBuilder = """
                                    ( "category":"chair" OR "category":"table" ) AND "price" < 20.0 AND "price" > 10.0 AND "_tags":"Tom" AND ( "_tags":"Hank" OR "_tags":"Tom" )
                                    """
        XCTAssertEqual(filterBuilder.build(), expectedFilterBuilder)
        
    }
    
    func testContains() {
        
        let filterBuilder = FilterBuilder()
        
        let tagA = FilterTag(value: "A")
        let tagB = FilterTag(value: "B")
        let tagC = FilterTag(value: "C")
        let numeric = FilterNumeric(attribute: "price", operator: .lessThan, value: 100)
        let facet = FilterFacet(attribute: "new", value: true)
        
        filterBuilder[.or("tags", ofType: FilterTag.self)] +++ [tagA, tagB]
        
        filterBuilder[.or("tags", ofType: FilterTag.self)] +++ "hm" +++ "other"
        
        filterBuilder[.or("numeric", ofType: FilterNumeric.self)] +++ ("size", 15...20) +++ ("price", .greaterThan, 100)
        
        filterBuilder[.and("others")]
            +++ numeric
            +++ facet
        
        filterBuilder[.and("some")]
            +++ ("price", .greaterThan, 20)
            +++ ("size", 15...20)
            +++ "someTag"
            +++ ("brand", "apple")
            +++ ("featured", true) +++ ("rating", 4)
        
        XCTAssertTrue(filterBuilder.contains(tagA))
        XCTAssertTrue(filterBuilder.contains(tagB))
        XCTAssertTrue(filterBuilder.contains(numeric))
        XCTAssertTrue(filterBuilder.contains(facet))
        XCTAssertTrue(filterBuilder.contains(tagA, in: .or("tags", ofType: FilterTag.self)))
        XCTAssertTrue(filterBuilder.contains(tagB, in: .or("tags", ofType: FilterTag.self)))
        XCTAssertTrue(filterBuilder.contains(numeric, in: .and("others")))
        XCTAssertTrue(filterBuilder.contains(facet, in: .and("others")))
        
        XCTAssertFalse(filterBuilder.contains(tagC))
        XCTAssertFalse(filterBuilder.contains(FilterFacet(attribute: "new", value: false)))
        XCTAssertFalse(filterBuilder.contains(tagC, in: .or("tags", ofType: FilterTag.self)))
        XCTAssertFalse(filterBuilder.contains(tagA, in: .and("others")))
        XCTAssertFalse(filterBuilder.contains(tagB, in: .and("others")))
        
    }
    
    func testReplaceFilter() {
        
        let filter1 = FilterFacet(attribute: Attribute("category"), value: "chair")
        let filter2 = FilterFacet(attribute: Attribute("isPromoted"), value: true)
        let filter3 = FilterFacet(attribute: Attribute("category"), value: "table")
        
        let filterBuilder = FilterBuilder()
        
        let group1: OrFilterGroup<FilterFacet> = .init(name: "group1")
        let group2: OrFilterGroup<FilterFacet> = .init(name: "group2")
        
        filterBuilder.add(filter1, to: group1)
        filterBuilder.add(filter1, to: group2)
        filterBuilder.add(filter3, to: group2)
        XCTAssertTrue(filterBuilder.contains(filter1))
        XCTAssertTrue(filterBuilder.contains(filter3))
        
        filterBuilder[group1].replace(filter1, by: filter2)
        filterBuilder[group2].replace(filter1, by: filter2)
        
        XCTAssertFalse(filterBuilder.contains(filter1))
        XCTAssertTrue(filterBuilder.contains(filter2))
        XCTAssertTrue(filterBuilder.contains(filter3))
        
        filterBuilder[group1].replace(filter1, by: filter3)
        filterBuilder[group2].replace(filter1, by: filter3)
        
        XCTAssertFalse(filterBuilder.contains(filter1))
        XCTAssertTrue(filterBuilder.contains(filter2))
        XCTAssertTrue(filterBuilder.contains(filter3))
        
    }
    
    func testReplaceAttribute() {
        
        let filter1 = FilterFacet(attribute: "price", value: "high")
        let filter2 = FilterFacet(attribute: "price", value: 15)
        let filter3 = FilterFacet(attribute: "category", value: "gifts")
        
        let group1: OrFilterGroup<FilterFacet> = .init(name: "group1")
        let group2: OrFilterGroup<FilterFacet> = .init(name: "group2")
        
        let filterBuilder = FilterBuilder()
        
        filterBuilder.add(filter1, to: group1)
        filterBuilder.addAll([filter2, filter3], to: group2)
        
        filterBuilder.replace(Attribute("price"), by: Attribute("someValue"))
        
        XCTAssertTrue(filterBuilder.contains(FilterFacet(attribute: Attribute("someValue"), value: "high")))
        XCTAssertTrue(filterBuilder.contains(FilterFacet(attribute: Attribute("someValue"), value: 15)))
        XCTAssertTrue(filterBuilder.contains(filter3))
        XCTAssertFalse(filterBuilder.contains(filter1))
        XCTAssertFalse(filterBuilder.contains(filter2))
        
    }

    func testMove() {
        
        let filterBuilder = FilterBuilder()

        let orGroup: OrFilterGroup = .or("tags", ofType: FilterTag.self)
        let andGroup: AndFilterGroup = .and("some")
        let anotherOrGroup: OrFilterGroup = .or("otherTags", ofType: FilterTag.self)
        let anotherAndGroup: AndFilterGroup = .and("other")
        
        let tagA = FilterTag(value: "a")
        let tagB = FilterTag(value: "b")
        let tagC = FilterTag(value: "c")
        let numeric = FilterNumeric(attribute: "price", operator: .greaterThan, value: 10)
        
        filterBuilder[orGroup] +++ tagA +++ tagB
        filterBuilder[andGroup] +++ tagC +++ numeric
        
        // Move or -> and
        XCTAssertTrue(filterBuilder[orGroup].move(tagA, to: andGroup))
        // Test consistency
        XCTAssertFalse(filterBuilder[orGroup].contains(tagA))
        XCTAssertTrue(filterBuilder[andGroup].contains(tagA))
        // Test impossibility to move it again
        XCTAssertFalse(filterBuilder[orGroup].move(tagA, to: andGroup))
        
        // Move and -> or
        XCTAssertTrue(filterBuilder[andGroup].move(tagC, to: orGroup))
        // Test consistency
        XCTAssertFalse(filterBuilder[andGroup].contains(tagC))
        XCTAssertTrue(filterBuilder[orGroup].contains(tagC))
        // Test impossibility to move it again
        XCTAssertFalse(filterBuilder[andGroup].move(tagC, to: orGroup))
        
        // Move or -> or
        XCTAssertTrue(filterBuilder[orGroup].move(tagC, to: anotherOrGroup))
        // Test consistency
        XCTAssertTrue(filterBuilder[anotherOrGroup].contains(tagC))
        XCTAssertFalse(filterBuilder[orGroup].contains(tagC))
        // Test impossibility to move it again
        XCTAssertFalse(filterBuilder[orGroup].move(tagC, to: anotherOrGroup))
        
        // Move and -> and
        XCTAssertTrue(filterBuilder[andGroup].move(numeric, to: anotherAndGroup))
        // Test consistency
        XCTAssertTrue(filterBuilder[anotherAndGroup].contains(numeric))
        XCTAssertFalse(filterBuilder[andGroup].contains(numeric))
        // Test impossibility to move it again
        XCTAssertFalse(filterBuilder[andGroup].move(numeric, to: anotherAndGroup))
    }
    
    func testRemove() {
        
        let filterBuilder = FilterBuilder()
        
        filterBuilder[.or("orTags", ofType: FilterTag.self)] +++ "a" +++ "b"
        filterBuilder[.and("any")] +++ FilterTag(value: "a") +++ FilterTag(value: "b") +++ FilterNumeric(attribute: "price", range: 1...10)
        
        XCTAssertTrue(filterBuilder.remove(FilterTag(value: "a")))
        XCTAssertFalse(filterBuilder.contains(FilterTag(value: "a")))
        
        // Try to delete one more time
        XCTAssertFalse(filterBuilder.remove(FilterTag(value: "a")))
        
        // Remove filter occuring in multiple groups from one group
        
        XCTAssertTrue(filterBuilder.remove(FilterTag(value: "b"), from: .and("any")))
        
        XCTAssertTrue(filterBuilder.contains(FilterTag(value: "b")))
        XCTAssertFalse(filterBuilder.contains(FilterTag(value: "b"), in: .and("any")))
        XCTAssertTrue(filterBuilder.contains(FilterTag(value: "b"), in: .or("orTags", ofType: FilterTag.self)))

        // Remove all from group
        filterBuilder.removeAll(from: .and("any"))
        XCTAssertTrue(filterBuilder[.and("any")].isEmpty)
        
        // Remove all anywhere
        filterBuilder.removeAll()
        XCTAssertTrue(filterBuilder.isEmpty)
        
    }
    
    func testSubscriptAndOperatorPlayground() {
        
        let filterBuilder = FilterBuilder()
        
        let filterFacet1 = FilterFacet(attribute: "category", value: "table")
        let filterFacet2 = FilterFacet(attribute: "category", value: "chair")
        let filterNumeric1 = FilterNumeric(attribute: "price", operator: .greaterThan, value: 10)
        let filterNumeric2 = FilterNumeric(attribute: "price", operator: .lessThan, value: 20)
        let filterTag1 = FilterTag(value: "Tom")
        
        filterBuilder[.or("a", ofType: FilterFacet.self)] +++ filterFacet1 --- filterFacet2
        filterBuilder[.and("b")] +++ [filterNumeric1] +++ filterTag1
        
        filterBuilder[.or("a", ofType: FilterFacet.self)] +++ [filterFacet1, filterFacet2]
        filterBuilder[.and("b")] +++ [filterNumeric1, filterNumeric2]
        
    }
    
    func testAndGroupSubscript() {
        let filterBuilder = FilterBuilder()
        
        let filter = FilterFacet(attribute: "category", value: "table")
        
        let group = AndFilterGroup(name: "group")
        
        filterBuilder[group] +++ filter

        XCTAssertTrue(filterBuilder.contains(filter))
        
    }
    
    func testOrGroupSubscript() {
        let filterBuilder = FilterBuilder()
        
        let filter = FilterFacet(attribute: "category", value: "table")
        
        let group = OrFilterGroup<FilterFacet>(name: "group")

        filterBuilder[group] +++ filter
        
        XCTAssertTrue(filterBuilder.contains(filter))
    }
    
    func testOrGroupAddAll() {
        let filterBuilder = FilterBuilder()
        let group = OrFilterGroup<FilterFacet>(name: "group")
        let filter1 = FilterFacet(attribute: "category", value: "table")
        let filter2 = FilterFacet(attribute: "category", value: "chair")
        filterBuilder.addAll([filter1, filter2], to: group)
        XCTAssertTrue(filterBuilder.contains(filter1))
        XCTAssertTrue(filterBuilder.contains(filter2))
    }
    
    func testAndGroupAddAll() {
        let filterBuilder = FilterBuilder()
        let group = AndFilterGroup(name: "group")
        let filterPrice = FilterNumeric(attribute: "price", operator: .greaterThan, value: 10)
        let filterSize = FilterNumeric(attribute: "size", operator: .greaterThan, value: 20)
        filterBuilder.addAll([filterPrice, filterSize], to: group)
        XCTAssertTrue(filterBuilder.contains(filterPrice))
        XCTAssertTrue(filterBuilder.contains(filterSize))
    }
    
    func testClearAttribute() {
        
        let filterNumeric1 = FilterNumeric(attribute: "price", operator: .greaterThan, value: 10)
        let filterNumeric2 = FilterNumeric(attribute: "price", operator: .lessThan, value: 20)
        let filterTag1 = FilterTag(value: "Tom")
        let filterTag2 = FilterTag(value: "Hank")
        
        let groupNumericsOr = OrFilterGroup<FilterNumeric>(name: "filterNumeric")
        let groupTagsOr = OrFilterGroup<FilterTag>(name: "filterTags")

        let filterBuilder = FilterBuilder()
        
        filterBuilder.addAll([filterNumeric1, filterNumeric2], to: groupNumericsOr)
        filterBuilder.addAll([filterTag1, filterTag2], to: groupTagsOr)

        filterBuilder.removeAll(for: Attribute("price"))
        
        XCTAssertFalse(filterBuilder.contains(filterNumeric1))
        XCTAssertFalse(filterBuilder.contains(filterNumeric2))
        XCTAssertTrue(filterBuilder.contains(filterTag1))
        XCTAssertTrue(filterBuilder.contains(filterTag2))
        
    }
    
    func testIsEmpty() {
        let filterBuilder = FilterBuilder()
        let filter = FilterNumeric(attribute: Attribute("price"), operator: .greaterThan, value: 10)
        let group = OrFilterGroup<FilterNumeric>(name: "group")
        XCTAssertTrue(filterBuilder.isEmpty)
        filterBuilder.add(filter, to: group)
        XCTAssertFalse(filterBuilder.isEmpty)
        filterBuilder.remove(filter)
        XCTAssertTrue(filterBuilder.isEmpty, filterBuilder.build())
    }
    
    func testClear() {
        let filterBuilder = FilterBuilder()
        let filterNumeric = FilterNumeric(attribute: Attribute("price"), operator: .greaterThan, value: 10)
        let filterTag = FilterTag(value: "Tom")
        let group = AndFilterGroup(name: "group")
        filterBuilder.add(filterNumeric, to: group)
        filterBuilder.add(filterTag, to: group)
        filterBuilder.removeAll()
        XCTAssertTrue(filterBuilder.isEmpty)
    }
    
    func testAndGroupOperators() {
        
        let filterBuilder = FilterBuilder()
        
        filterBuilder[.and("g")] +++ "tag1"
        
        XCTAssertTrue(filterBuilder.contains(FilterTag(value:"tag1")))
        
        filterBuilder[.and("g")] +++ [FilterTag(value:"tag2"), FilterTag(value:"tag3")]
        
        XCTAssertTrue(filterBuilder.contains(FilterTag(value:"tag2")))
        XCTAssertTrue(filterBuilder.contains(FilterTag(value:"tag3")))

        filterBuilder[.and("g")] +++ ("price", .greaterThan, 100)
        
        XCTAssertTrue(filterBuilder.contains(FilterNumeric(attribute: "price", operator: .greaterThan, value: 100)))
        
        filterBuilder[.and("g")] +++ ("size", 30...40)
        
        XCTAssertTrue(filterBuilder.contains(FilterNumeric(attribute: "size", range: 30...40)))
        
        filterBuilder[.and("g")] +++ ("brand", "sony")
        
        XCTAssertTrue(filterBuilder.contains(FilterFacet(attribute: "brand", value: "sony")))

        filterBuilder[.and("g")] --- "tag1"
        
        XCTAssertFalse(filterBuilder.contains(FilterTag(value:"tag1")))
        
        filterBuilder[.and("g")] --- [FilterTag(value:"tag2"), FilterTag(value:"tag3")]
        
        XCTAssertFalse(filterBuilder.contains(FilterTag(value:"tag2")))
        XCTAssertFalse(filterBuilder.contains(FilterTag(value:"tag3")))

        filterBuilder[.and("g")] --- ("price", .greaterThan, 100)
        
        XCTAssertFalse(filterBuilder.contains(FilterNumeric(attribute: "price", operator: .greaterThan, value: 100)))

        filterBuilder[.and("g")] --- ("size", 30...40)
        
        XCTAssertFalse(filterBuilder.contains(FilterNumeric(attribute: "size", range: 30...40)))

        filterBuilder[.and("g")] --- ("brand", "sony")

        XCTAssertFalse(filterBuilder.contains(FilterFacet(attribute: "brand", value: "sony")))

    }
    
    func testOrGroupOperators() {
        
        let filterBuilder = FilterBuilder()
        
        let tagGroup = OrFilterGroup<FilterTag>(name: "g")
        let facetGroup = OrFilterGroup<FilterFacet>(name: "g")
        let numericGroup = OrFilterGroup<FilterNumeric>(name: "g")
        
        filterBuilder[tagGroup] +++ "tag1"
        
        XCTAssertTrue(filterBuilder.contains(FilterTag(value: "tag1")))
        
        filterBuilder[tagGroup] +++ [FilterTag(value: "tag2"), FilterTag(value: "tag3")]
        
        XCTAssertTrue(filterBuilder.contains(FilterTag(value: "tag2")))
        XCTAssertTrue(filterBuilder.contains(FilterTag(value: "tag3")))

        filterBuilder[facetGroup] +++ ("brand", "sony")
        
        XCTAssertTrue(filterBuilder.contains(FilterFacet(attribute: "brand", value: "sony")))
        
        filterBuilder[numericGroup] +++ ("price", .greaterThan, 100)
        
        XCTAssertTrue(filterBuilder.contains(FilterNumeric(attribute: "price", operator: .greaterThan, value: 100)))
        
        filterBuilder[numericGroup] +++ ("size", 30...40)
        
        XCTAssertTrue(filterBuilder.contains(FilterNumeric(attribute: "size", range: 30...40)))
        
        filterBuilder[tagGroup] --- "tag1"
        
        XCTAssertFalse(filterBuilder.contains(FilterTag(value: "tag1")))
        
        filterBuilder[tagGroup] --- [FilterTag(value: "tag2"), FilterTag(value: "tag3")]
        
        XCTAssertFalse(filterBuilder.contains(FilterTag(value: "tag2")))
        XCTAssertFalse(filterBuilder.contains(FilterTag(value: "tag3")))

        filterBuilder[facetGroup] --- ("brand", "sony")
        
        XCTAssertFalse(filterBuilder.contains(FilterFacet(attribute: "brand", value: "sony")))

        filterBuilder[numericGroup] --- ("price", .greaterThan, 100)
        
        XCTAssertFalse(filterBuilder.contains(FilterNumeric(attribute: "price", operator: .greaterThan, value: 100)))

        filterBuilder[numericGroup] --- ("size", 30...40)
        
        XCTAssertFalse(filterBuilder.contains(FilterNumeric(attribute: "price", range: 30...40)))
        
        XCTAssertTrue(filterBuilder.isEmpty)
        
    }
    
  


    // MARK: Build & parse

    /// Test serializing a query into a URL query string.
//    func testFacetFilters() {
//        let params = SearchParameters()
//
//        params.addFacetRefinement(name: "foo", value: "bar1")
//        XCTAssertEqual(params.buildFilters(), "\"foo\":\"bar1\"")
//
//        // One conjunctive facet with two refinements.
//        params.addFacetRefinement(name: "foo", value: "bar2")
//        XCTAssertEqual(params.buildFilters(), "\"foo\":\"bar1\" AND \"foo\":\"bar2\"")
//
//        // Two conjunctive facets with one refinement.
//        params.removeFacetRefinement(name: "foo", value: "bar1")
//        params.addFacetRefinement(name: "abc", value: "xyz")
//        XCTAssertEqual(params.buildFilters(), "\"abc\":\"xyz\" AND \"foo\":\"bar2\"")
//
//        // Two conjunctive facets with two refinements (one negated).
//        params.addFacetRefinement(name: "foo", value: "bar3")
//        params.addFacetRefinement(name: "abc", value: "tuv", inclusive: false)
//        XCTAssertEqual(params.buildFilters(), "\"abc\":\"xyz\" AND NOT \"abc\":\"tuv\" AND \"foo\":\"bar2\" AND \"foo\":\"bar3\"")
//
//        // One conjunctive facet and one disjunctive facet.
//        params.setFacet(withName: "abc", disjunctive: true)
//        XCTAssertEqual(params.buildFilters(), "(\"abc\":\"xyz\" OR NOT \"abc\":\"tuv\") AND \"foo\":\"bar2\" AND \"foo\":\"bar3\"")
//
//        // Two disjunctive facets.
//        params.setFacet(withName: "foo", disjunctive: true)
//        XCTAssertEqual(params.buildFilters(), "(\"abc\":\"xyz\" OR NOT \"abc\":\"tuv\") AND (\"foo\":\"bar2\" OR \"foo\":\"bar3\")")
//
//        // Disjunctive facet with only one refinement.
//        params.removeFacetRefinement(name: "abc", value: "tuv")
//        XCTAssertEqual(params.buildFilters(), "(\"abc\":\"xyz\") AND (\"foo\":\"bar2\" OR \"foo\":\"bar3\")")
//
//        // Remove all refinements: facet should disappear from params.
//        params.removeFacetRefinement(name: "abc", value: "xyz")
//        XCTAssertEqual(params.buildFilters(), "(\"foo\":\"bar2\" OR \"foo\":\"bar3\")")
//
//        params.clearFacetRefinements(name: "foo")
//        XCTAssertNil(params.buildFilters())
//        XCTAssertNil(params.buildFiltersFromFacets())
//
//        // TODO: A test on adding same filters twice and see if the Set actually handles well this case.
//    }
//
//    func testFacetExistence() {
//        let params = SearchParameters()
//        XCTAssertFalse(params.hasRefinements())
//        XCTAssertFalse(params.hasFacetRefinements())
//        XCTAssertFalse(params.hasFacetRefinements(name: "foo"))
//
//        params.addFacetRefinement(name: "foo", value: "xxx")
//        XCTAssertTrue(params.hasRefinements())
//        XCTAssertTrue(params.hasFacetRefinements())
//        XCTAssertTrue(params.hasFacetRefinements(name: "foo"))
//        XCTAssertFalse(params.hasFacetRefinements(name: "bar"))
//        XCTAssertTrue(params.hasFacetRefinement(name: "foo", value: "xxx"))
//        XCTAssertFalse(params.hasFacetRefinement(name: "foo", value: "yyy"))
//        XCTAssertFalse(params.hasFacetRefinement(name: "bar", value: "baz"))
//
//        params.toggleFacetRefinement(name: "foo", value: "xxx")
//        XCTAssertFalse(params.hasRefinements())
//        XCTAssertFalse(params.hasFacetRefinements())
//        XCTAssertFalse(params.hasFacetRefinements(name: "foo"))
//        XCTAssertFalse(params.hasFacetRefinement(name: "foo", value: "xxx"))
//
//        params.toggleFacetRefinement(name: "bar", value: "baz")
//        XCTAssertTrue(params.hasRefinements())
//        XCTAssertTrue(params.hasFacetRefinements())
//        XCTAssertTrue(params.hasFacetRefinements(name: "bar"))
//        XCTAssertTrue(params.hasFacetRefinement(name: "bar", value: "baz"))
//    }
//
//    func testNumericFilters() {
//        let params = SearchParameters()
//
//        // Empty params should produce empty string.
//        XCTAssertNil(params.buildFilters())
//        XCTAssertNil(params.buildFiltersFromNumerics())
//
//        // One conjunctive numeric with one refinement.
//        params.addNumericRefinement("foo", .greaterThanOrEqual, 2)
//        XCTAssertEqual(params.buildFilters(), "\"foo\" >= 2")
//
//        // One conjunctive numeric with two refinements.
//        params.addNumericRefinement("foo", .lessThan, 3.0)
//        XCTAssertEqual(params.buildFilters(), "\"foo\" >= 2 AND \"foo\" < 3")
//
//        // Update One conjunctive numeric with 2 refinements.
//        params.updateNumericRefinement("foo", .greaterThanOrEqual, 3)
//        params.updateNumericRefinement("foo", .lessThan, 4.0)
//        XCTAssertEqual(params.buildFilters(), "\"foo\" >= 3 AND \"foo\" < 4")
//
//        // Two conjunctive numeric with one refinement.
//        params.removeNumericRefinement(NumericRefinement("foo", .greaterThanOrEqual, 3.0))
//        params.addNumericRefinement(NumericRefinement("bar", .greaterThan, 456.789))
//        XCTAssertEqual(params.buildFilters(), "\"bar\" > 456.789 AND \"foo\" < 4")
//
//        // Two conjunctive numerics with two refinements (one negated).
//        params.addNumericRefinement("foo", .notEqual, 0)
//        params.addNumericRefinement("bar", .equal, 0, inclusive: false)
//        XCTAssertEqual(params.buildFilters(), "\"bar\" > 456.789 AND NOT \"bar\" = 0 AND \"foo\" < 4 AND \"foo\" != 0")
//
//        // One conjunctive numeric and one disjunctive.
//        params.setNumeric(withName: "foo", disjunctive: true)
//        XCTAssertEqual(params.buildFilters(), "\"bar\" > 456.789 AND NOT \"bar\" = 0 AND (\"foo\" < 4 OR \"foo\" != 0)")
//
//        // Two disjunctive numeric.
//        params.setNumeric(withName: "bar", disjunctive: true)
//        XCTAssertEqual(params.buildFilters(), "(\"bar\" > 456.789 OR NOT \"bar\" = 0) AND (\"foo\" < 4 OR \"foo\" != 0)")
//
//        // Disjunctive numeric with only one refinement.
//        params.removeNumericRefinement("foo", .lessThan, 4)
//        XCTAssertEqual(params.buildFilters(), "(\"bar\" > 456.789 OR NOT \"bar\" = 0) AND (\"foo\" != 0)")
//
//        // Remove all refinements: numerics should disappear from params.
//        params.removeNumericRefinement("foo", .notEqual, 0.0)
//        XCTAssertEqual(params.buildFilters(), "(\"bar\" > 456.789 OR NOT \"bar\" = 0)")
//        XCTAssertEqual(params.buildFilters(), params.buildFiltersFromNumerics())
//        params.clearNumericRefinements(name: "bar")
//        XCTAssertNil(params.buildFilters())
//        XCTAssertNil(params.buildFiltersFromNumerics())
//    }
//
//    func testBooleanNumeric() {
//        // Boolean numeric params should use numeric values 0 and 1.
//        let params = SearchParameters()
//        params.addNumericRefinement("boolean", .equal, false)
//        XCTAssertEqual(params.buildFilters(), "\"boolean\" = 0")
//        params.clear()
//        params.addNumericRefinement("boolean", .equal, true)
//        XCTAssertEqual(params.buildFilters(), "\"boolean\" = 1")
//    }
//
//    func testNumericExistence() {
//        let params = SearchParameters()
//        XCTAssertFalse(params.hasRefinements())
//        XCTAssertFalse(params.hasNumericRefinements())
//        XCTAssertFalse(params.hasNumericRefinements(name: "foo"))
//
//        params.addNumericRefinement("foo", .greaterThan, -1)
//        XCTAssertTrue(params.hasRefinements())
//        XCTAssertTrue(params.hasNumericRefinements())
//        XCTAssertTrue(params.hasNumericRefinements(name: "foo"))
//        XCTAssertFalse(params.hasNumericRefinements(name: "bar"))
//
//        params.updateNumericRefinement("foo", .greaterThan, 5)
//        params.updateNumericRefinement("baz", .greaterThan, 3)
//        XCTAssertTrue(params.hasRefinements())
//        XCTAssertTrue(params.hasNumericRefinements())
//        XCTAssertTrue(params.hasNumericRefinements(name: "foo"))
//        XCTAssertTrue(params.hasNumericRefinements(name: "baz"))
//        XCTAssertFalse(params.hasNumericRefinements(name: "bar"))
//
//        params.removeNumericRefinement("foo", .greaterThan, 5)
//        params.removeNumericRefinements(where: { $0.name == "baz" })
//        XCTAssertFalse(params.hasRefinements())
//        XCTAssertFalse(params.hasNumericRefinements())
//        XCTAssertFalse(params.hasNumericRefinements())
//        XCTAssertFalse(params.hasNumericRefinements(name: "foo"))
//    }
//
//    /// Test combining facet refinements and numeric refinements.
//    ///
//    func testFacetAndNumeric() {
//        let params = SearchParameters()
//        params.addNumericRefinement("foo", .greaterThanOrEqual, 123)
//        params.addFacetRefinement(name: "abc", value: "something")
//        params.addNumericRefinement("bar", .lessThan, 456.789)
//        params.addFacetRefinement(name: "xyz", value: "other")
//        XCTAssertEqual(params.buildFilters(), "\"abc\":\"something\" AND \"xyz\":\"other\" AND \"bar\" < 456.789 AND \"foo\" >= 123")
//        XCTAssertEqual(params.buildFiltersFromFacets(), "\"abc\":\"something\" AND \"xyz\":\"other\"")
//        XCTAssertEqual(params.buildFiltersFromNumerics(), "\"bar\" < 456.789 AND \"foo\" >= 123")
//
//        let params2 = SearchParameters(from: params)
//        params2.clearNumericRefinements()
//        XCTAssertEqual(params2.buildFilters(), "\"abc\":\"something\" AND \"xyz\":\"other\"")
//        XCTAssertEqual(params2.buildFiltersFromFacets(), "\"abc\":\"something\" AND \"xyz\":\"other\"")
//        XCTAssertNil(params2.buildFiltersFromNumerics())
//
//        let params3 = SearchParameters(from: params)
//        params3.clearFacetRefinements()
//        XCTAssertEqual(params3.buildFilters(), "\"bar\" < 456.789 AND \"foo\" >= 123")
//        XCTAssertEqual(params3.buildFiltersFromNumerics(), "\"bar\" < 456.789 AND \"foo\" >= 123")
//        XCTAssertNil(params3.buildFiltersFromFacets())
//    }
}
