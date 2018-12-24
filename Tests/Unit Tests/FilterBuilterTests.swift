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

        let filterFacet1 = FilterFacet(attribute: Attribute("category"), value: "table")
        let filterFacet2 = FilterFacet(attribute: Attribute("category"), value: "chair")
        let filterNumeric1 = FilterNumeric(attribute: "price", operator: NumericOperator.greaterThan, value: 10)
        let filterNumeric2 = FilterNumeric(attribute: "price", operator: .lessThan, value: 20)
        let filterTag1 = FilterTag(value: "Tom")
        let filterTag2 = FilterTag(value: "Hank")

        let groupFacets = OrFilterGroup<FilterFacet>(name: "filterFacets")
        let groupFacetsOtherInstance = OrFilterGroup<FilterFacet>(name: "filterFacets")
        let groupNumerics = AndFilterGroup(name: "filterNumerics")
        let groupTagsOr = OrFilterGroup<FilterTag>(name: "filterTags")
        let groupTagsAnd = AndFilterGroup(name: "filterTags")

        filterBuilder.add(filter: filterFacet1, in: groupFacets)
        // Make sure that if we re-create a group instance, filters will stay in same group bracket
        filterBuilder.add(filter: filterFacet2, in: groupFacetsOtherInstance)

        filterBuilder.add(filter: filterNumeric1, in: groupNumerics)
        filterBuilder.add(filter: filterNumeric2, in: groupNumerics)
         // Repeat once to see if the Set rejects same filter
        filterBuilder.add(filter: filterNumeric2, in: groupNumerics)

        filterBuilder.addAll(filters: [filterTag1, filterTag2], in: groupTagsOr)
        filterBuilder.add(filter: filterTag1, in: groupTagsAnd)
        let expectedFilterBuilder = """
                                    ( "category":"chair" OR "category":"table" ) AND "price" < 20.0 AND "price" > 10.0 AND "_tags":"Tom" AND ( "_tags":"Hank" OR "_tags":"Tom" )
                                    """
        XCTAssertEqual(filterBuilder.build(), expectedFilterBuilder)
        
        XCTAssertTrue(filterBuilder.contains(filter: filterFacet1))
        
        let missingFilter = FilterFacet(attribute: Attribute("bla"), value: false)
        XCTAssertFalse(filterBuilder.contains(filter: missingFilter))
        
        filterBuilder.remove(filter: filterTag1, in: groupTagsAnd) // existing one
        filterBuilder.remove(filter: filterTag1, in: groupTagsAnd) // remove one more time
        filterBuilder.remove(filter: FilterTag(value: "unexisting"), in: groupTagsOr) // remove one that does not exist
        filterBuilder.remove(filter: filterFacet1) // Remove in all groups

        let expectedFilterBuilder2 = """
                                    "category":"chair" AND "price" < 20.0 AND "price" > 10.0 AND ( "_tags":"Hank" OR "_tags":"Tom" )
                                    """
        XCTAssertEqual(filterBuilder.build(), expectedFilterBuilder2)

        filterBuilder.removeAll(filters: [filterNumeric1, filterNumeric2])

        let expectedFilterBuilder3 = """
                                    "category":"chair" AND ( "_tags":"Hank" OR "_tags":"Tom" )
                                    """
        XCTAssertEqual(filterBuilder.build(), expectedFilterBuilder3)
        
    }
    
    func testSubscriptAndOperatorPlayground() {
        
        let filterBuilder = FilterBuilder()
        
        let filterFacet1 = FilterFacet(attribute: "category", value: "table")
        let filterFacet2 = FilterFacet(attribute: "category", value: "chair")
        let filterNumeric1 = FilterNumeric(attribute: "price", operator: .greaterThan, value: 10)
        let filterNumeric2 = FilterNumeric(attribute: "price", operator: .lessThan, value: 20)
        let filterTag1 = FilterTag(value: "Tom")
        let filterTag2 = FilterTag(value: "Hank")
        
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

        XCTAssertTrue(filterBuilder.contains(filter: filter))
        
    }
    
    func testOrGroupSubscript() {
        let filterBuilder = FilterBuilder()
        
        let filter = FilterFacet(attribute: "category", value: "table")
        
        let group = OrFilterGroup<FilterFacet>(name: "group")

        filterBuilder[group] +++ filter
        
        XCTAssertTrue(filterBuilder.contains(filter: filter))
    }
    
    func testOrGroupAddAll() {
        let filterBuilder = FilterBuilder()
        let group = OrFilterGroup<FilterFacet>(name: "group")
        let filter1 = FilterFacet(attribute: "category", value: "table")
        let filter2 = FilterFacet(attribute: "category", value: "chair")
        filterBuilder.addAll(filters: [filter1, filter2], in: group)
        XCTAssertTrue(filterBuilder.contains(filter: filter1))
        XCTAssertTrue(filterBuilder.contains(filter: filter2))
    }
    
    func testAndGroupAddAll() {
        let filterBuilder = FilterBuilder()
        let group = AndFilterGroup(name: "group")
        let filterPrice = FilterNumeric(attribute: "price", operator: .greaterThan, value: 10)
        let filterSize = FilterNumeric(attribute: "size", operator: .greaterThan, value: 20)
        filterBuilder.addAll(filters: [filterPrice, filterSize], in: group)
        XCTAssertTrue(filterBuilder.contains(filter: filterPrice))
        XCTAssertTrue(filterBuilder.contains(filter: filterSize))
    }
    
    func testClearAttribute() {
        
        let filterNumeric1 = FilterNumeric(attribute: "price", operator: .greaterThan, value: 10)
        let filterNumeric2 = FilterNumeric(attribute: "price", operator: .lessThan, value: 20)
        let filterTag1 = FilterTag(value: "Tom")
        let filterTag2 = FilterTag(value: "Hank")
        
        let groupNumericsOr = OrFilterGroup<FilterNumeric>(name: "filterNumeric")
        let groupTagsOr = OrFilterGroup<FilterTag>(name: "filterTags")

        let filterBuilder = FilterBuilder()
        
        filterBuilder.addAll(filters: [filterNumeric1, filterNumeric2], in: groupNumericsOr)
        filterBuilder.addAll(filters: [filterTag1, filterTag2], in: groupTagsOr)

        filterBuilder.removeAll(for: Attribute("price"))
        
        XCTAssertFalse(filterBuilder.contains(filter: filterNumeric1))
        XCTAssertFalse(filterBuilder.contains(filter: filterNumeric2))
        XCTAssertTrue(filterBuilder.contains(filter: filterTag1))
        XCTAssertTrue(filterBuilder.contains(filter: filterTag2))
        
    }
    
    func testIsEmpty() {
        let filterBuilder = FilterBuilder()
        let filter = FilterNumeric(attribute: Attribute("price"), operator: .greaterThan, value: 10)
        let group = OrFilterGroup<FilterNumeric>(name: "group")
        XCTAssertTrue(filterBuilder.isEmpty)
        filterBuilder.add(filter: filter, in: group)
        XCTAssertFalse(filterBuilder.isEmpty)
        filterBuilder.remove(filter: filter)
        XCTAssertTrue(filterBuilder.isEmpty, filterBuilder.build())
    }
    
    func testClear() {
        let filterBuilder = FilterBuilder()
        let filterNumeric = FilterNumeric(attribute: Attribute("price"), operator: .greaterThan, value: 10)
        let filterTag = FilterTag(value: "Tom")
        let group = AndFilterGroup(name: "group")
        filterBuilder.add(filter: filterNumeric, in: group)
        filterBuilder.add(filter: filterTag, in: group)
        filterBuilder.removeAll()
        XCTAssertTrue(filterBuilder.isEmpty)
    }
    
    func testReplaceAttribute() {
        
        let filter1 = FilterFacet(attribute: "price", value: "high")
        let filter2 = FilterFacet(attribute: "price", value: 15)
        let filter3 = FilterFacet(attribute: "category", value: "gifts")
        
        let group1: OrFilterGroup<FilterFacet> = .init(name: "group1")
        let group2: OrFilterGroup<FilterFacet> = .init(name: "group2")
        
        let filterBuilder = FilterBuilder()
        
        filterBuilder.add(filter: filter1, in: group1)
        filterBuilder.addAll(filters: [filter2, filter3], in: group2)
        
        filterBuilder.replace(Attribute("price"), by: Attribute("someValue"))
        
        XCTAssertTrue(filterBuilder.contains(filter: FilterFacet(attribute: Attribute("someValue"), value: "high")))
        XCTAssertTrue(filterBuilder.contains(filter: FilterFacet(attribute: Attribute("someValue"), value: 15)))
        XCTAssertTrue(filterBuilder.contains(filter: filter3))
        XCTAssertFalse(filterBuilder.contains(filter: filter1))
        XCTAssertFalse(filterBuilder.contains(filter: filter2))
        
    }
    
    func testReplaceFilter() {
        
        let filter1 = FilterFacet(attribute: Attribute("category"), value: "chair")
        let filter2 = FilterFacet(attribute: Attribute("isPromoted"), value: true)
        let filter3 = FilterFacet(attribute: Attribute("category"), value: "table")
        
        let filterBuilder = FilterBuilder()
        
        let group1: OrFilterGroup<FilterFacet> = .init(name: "group1")
        let group2: OrFilterGroup<FilterFacet> = .init(name: "group2")
        
        filterBuilder.add(filter: filter1, in: group1)
        filterBuilder.add(filter: filter1, in: group2)
        filterBuilder.add(filter: filter3, in: group2)
        XCTAssertTrue(filterBuilder.contains(filter: filter1))
        XCTAssertTrue(filterBuilder.contains(filter: filter3))
        
        filterBuilder[group1].replace(filter1, by: filter2)
        filterBuilder[group2].replace(filter1, by: filter2)

        XCTAssertFalse(filterBuilder.contains(filter: filter1))
        XCTAssertTrue(filterBuilder.contains(filter: filter2))
        XCTAssertTrue(filterBuilder.contains(filter: filter3))

        filterBuilder[group1].replace(filter1, by: filter3)
        filterBuilder[group2].replace(filter1, by: filter3)
        
        XCTAssertFalse(filterBuilder.contains(filter: filter1))
        XCTAssertTrue(filterBuilder.contains(filter: filter2))
        XCTAssertTrue(filterBuilder.contains(filter: filter3))
        
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
