//
//  FilterBuilderTests.swift
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
    
    func testInversion() {
        
        let filterBuilder = FilterBuilder()
        
        filterBuilder[.or("a")] +++ FilterTag(value: "tagA", isInverted: true) +++ FilterTag(value: "tagB", isInverted: true)
        filterBuilder[.or("b")] +++ FilterFacet(attribute: "size", value: 40, isInverted: true) +++ FilterFacet(attribute: "featured", value: true, isInverted: true)
        
        let expectedResult = "( NOT \"_tags\":\"tagA\" OR NOT \"_tags\":\"tagB\" ) AND ( NOT \"featured\":\"true\" OR NOT \"size\":\"40.0\" )"
        
        XCTAssertEqual(filterBuilder.build(), expectedResult)
        
        let expectedResultIgnoringInversion = "( \"_tags\":\"tagA\" OR \"_tags\":\"tagB\" ) AND ( \"featured\":\"true\" OR \"size\":\"40.0\" )"
        
        XCTAssertEqual(filterBuilder.build(ignoringInversion: true), expectedResultIgnoringInversion)

        
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
        
        let expectedResult = """
                                    ( "category":"chair" OR "category":"table" ) AND "price" < 20.0 AND "price" > 10.0 AND "_tags":"Tom" AND ( "_tags":"Hank" OR "_tags":"Tom" )
                                    """
        
        XCTAssertEqual(filterBuilder.build(), expectedResult)
        
    }
    
    func testContains() {
        
        let filterBuilder = FilterBuilder()
        
        let tagA = FilterTag(value: "A")
        let tagB = FilterTag(value: "B")
        let tagC = FilterTag(value: "C")
        let numeric = FilterNumeric(attribute: "price", operator: .lessThan, value: 100)
        let facet = FilterFacet(attribute: "new", value: true)
        
        filterBuilder[.or("tags")] +++ [tagA, tagB]
        
        filterBuilder[.or("tags")] +++ "hm" +++ "other"
        
        filterBuilder[.or("numeric")] +++ ("size", 15...20) +++ ("price", .greaterThan, 100)
        
        filterBuilder[.and("others")]
            +++ numeric
            +++ facet
        
        filterBuilder[.and("some")]
            +++ ("price", .greaterThan, 20)
            +++ ("size", 15...20)
            +++ "someTag"
            +++ [("brand", "apple"), ("featured", true), ("rating", 4)]
        
        XCTAssertTrue(filterBuilder.contains(tagA))
        XCTAssertTrue(filterBuilder.contains(tagB))
        XCTAssertTrue(filterBuilder.contains(numeric))
        XCTAssertTrue(filterBuilder.contains(facet))
        XCTAssertTrue(filterBuilder.contains(tagA, in: .or("tags")))
        XCTAssertTrue(filterBuilder.contains(tagB, in: .or("tags")))
        XCTAssertTrue(filterBuilder.contains(numeric, in: .and("others")))
        XCTAssertTrue(filterBuilder.contains(facet, in: .and("others")))
        
        XCTAssertFalse(filterBuilder.contains(tagC))
        XCTAssertFalse(filterBuilder.contains(FilterFacet(attribute: "new", value: false)))
        XCTAssertFalse(filterBuilder.contains(tagC, in: .or("tags")))
        XCTAssertFalse(filterBuilder.contains(tagA, in: .and("others")))
        XCTAssertFalse(filterBuilder.contains(tagB, in: .and("others")))
        
        let expectedResult = """
        ( "price" > 100.0 OR "size":15.0 TO 20.0 ) AND "new":"true" AND "price" < 100.0 AND "_tags":"someTag" AND "brand":"apple" AND "featured":"true" AND "price" > 20.0 AND "rating":"4.0" AND "size":15.0 TO 20.0 AND ( "_tags":"A" OR "_tags":"B" OR "_tags":"hm" OR "_tags":"other" )
        """
        
        XCTAssertEqual(filterBuilder.build(), expectedResult)
        
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
        
        let expectedResult = """
        ( "category":"table" OR "isPromoted":"true" ) AND ( "category":"table" OR "isPromoted":"true" )
        """
        
        XCTAssertEqual(filterBuilder.build(), expectedResult)
        
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
        
        let expectedResult = """
        "someValue":"high" AND ( "category":"gifts" OR "someValue":"15.0" )
        """
        
        XCTAssertEqual(filterBuilder.build(), expectedResult)
        
    }

    func testMove() {
        
        let filterBuilder = FilterBuilder()

        let orGroup: OrFilterGroup<FilterTag> = .or("tags")
        let andGroup: AndFilterGroup = .and("some")
        let anotherOrGroup: OrFilterGroup<FilterTag> = .or("otherTags")
        let anotherAndGroup: AndFilterGroup = .and("other")
        
        let tagA = FilterTag(value: "a")
        let tagB = FilterTag(value: "b")
        let tagC = FilterTag(value: "c")
        let numeric = FilterNumeric(attribute: "price", operator: .greaterThan, value: 10)
        
        filterBuilder[orGroup] +++ tagA +++ tagB
        filterBuilder[andGroup] +++ tagC +++ numeric
        
        XCTAssertEqual(filterBuilder.build(), """
        "_tags":"c" AND "price" > 10.0 AND ( "_tags":"a" OR "_tags":"b" )
        """)
        
        // Move or -> and
        XCTAssertTrue(filterBuilder[orGroup].move(tagA, to: andGroup))
        // Test consistency
        XCTAssertFalse(filterBuilder[orGroup].contains(tagA))
        XCTAssertTrue(filterBuilder[andGroup].contains(tagA))
        // Test impossibility to move it again
        XCTAssertFalse(filterBuilder[orGroup].move(tagA, to: andGroup))
        
        XCTAssertEqual(filterBuilder.build(), """
        "_tags":"a" AND "_tags":"c" AND "price" > 10.0 AND "_tags":"b"
        """)
        
        // Move and -> or
        XCTAssertTrue(filterBuilder[andGroup].move(tagC, to: orGroup))
        // Test consistency
        XCTAssertFalse(filterBuilder[andGroup].contains(tagC))
        XCTAssertTrue(filterBuilder[orGroup].contains(tagC))
        // Test impossibility to move it again
        XCTAssertFalse(filterBuilder[andGroup].move(tagC, to: orGroup))
        
        XCTAssertEqual(filterBuilder.build(), """
        "_tags":"a" AND "price" > 10.0 AND ( "_tags":"b" OR "_tags":"c" )
        """)
        
        // Move or -> or
        XCTAssertTrue(filterBuilder[orGroup].move(tagC, to: anotherOrGroup))
        // Test consistency
        XCTAssertTrue(filterBuilder[anotherOrGroup].contains(tagC))
        XCTAssertFalse(filterBuilder[orGroup].contains(tagC))
        // Test impossibility to move it again
        XCTAssertFalse(filterBuilder[orGroup].move(tagC, to: anotherOrGroup))
        
        XCTAssertEqual(filterBuilder.build(), """
        "_tags":"c" AND "_tags":"a" AND "price" > 10.0 AND "_tags":"b"
        """)
        
        // Move and -> and
        XCTAssertTrue(filterBuilder[andGroup].move(numeric, to: anotherAndGroup))
        // Test consistency
        XCTAssertTrue(filterBuilder[anotherAndGroup].contains(numeric))
        XCTAssertFalse(filterBuilder[andGroup].contains(numeric))
        // Test impossibility to move it again
        XCTAssertFalse(filterBuilder[andGroup].move(numeric, to: anotherAndGroup))
        
        XCTAssertEqual(filterBuilder.build(), """
        "price" > 10.0 AND "_tags":"c" AND "_tags":"a" AND "_tags":"b"
        """)

    }
    
    func testRemove() {
        
        let filterBuilder = FilterBuilder()
        
        filterBuilder[.or("orTags")] +++ "a" +++ "b"
        filterBuilder[.and("any")] +++ FilterTag(value: "a") +++ FilterTag(value: "b") +++ FilterNumeric(attribute: "price", range: 1...10)
        
        XCTAssertEqual(filterBuilder.build(), """
        "_tags":"a" AND "_tags":"b" AND "price":1.0 TO 10.0 AND ( "_tags":"a" OR "_tags":"b" )
        """)
        
        XCTAssertTrue(filterBuilder.remove(FilterTag(value: "a")))
        XCTAssertFalse(filterBuilder.contains(FilterTag(value: "a")))
        
        XCTAssertEqual(filterBuilder.build(), """
        "_tags":"b" AND "price":1.0 TO 10.0 AND "_tags":"b"
        """)
        
        // Try to delete one more time
        XCTAssertFalse(filterBuilder.remove(FilterTag(value: "a")))
        
        XCTAssertEqual(filterBuilder.build(), """
        "_tags":"b" AND "price":1.0 TO 10.0 AND "_tags":"b"
        """)
        
        // Remove filter occuring in multiple groups from one group
        
        XCTAssertTrue(filterBuilder.remove(FilterTag(value: "b"), from: .and("any")))
        
        XCTAssertTrue(filterBuilder.contains(FilterTag(value: "b")))
        XCTAssertFalse(filterBuilder.contains(FilterTag(value: "b"), in: .and("any")))
        XCTAssertTrue(filterBuilder.contains(FilterTag(value: "b"), in: .or("orTags")))
        
        XCTAssertEqual(filterBuilder.build(), """
        "price":1.0 TO 10.0 AND "_tags":"b"
        """)

        // Remove all from group
        filterBuilder.removeAll(from: .and("any"))
        XCTAssertTrue(filterBuilder[.and("any")].isEmpty)
        
        XCTAssertEqual(filterBuilder.build(), """
        "_tags":"b"
        """)
        
        // Remove all anywhere
        filterBuilder.removeAll()
        XCTAssertTrue(filterBuilder.isEmpty)
        
        XCTAssertNil(filterBuilder.build())
        
    }
    
    func testSubscriptAndOperatorPlayground() {
        
        let filterBuilder = FilterBuilder()
        
        let filterFacet1 = FilterFacet(attribute: "category", value: "table")
        let filterFacet2 = FilterFacet(attribute: "category", value: "chair")
        let filterNumeric1 = FilterNumeric(attribute: "price", operator: .greaterThan, value: 10)
        let filterNumeric2 = FilterNumeric(attribute: "price", operator: .lessThan, value: 20)
        let filterTag1 = FilterTag(value: "Tom")
        
        filterBuilder[.or("a")] +++ filterFacet1 --- filterFacet2
        
        XCTAssertEqual(filterBuilder.build(), """
        "category":"table"
        """)
        
        filterBuilder[.and("b")] +++ [filterNumeric1] +++ filterTag1
        
        XCTAssertEqual(filterBuilder.build(), """
        "category":"table" AND "_tags":"Tom" AND "price" > 10.0
        """)
        
        filterBuilder[.or("a")] +++ [filterFacet1, filterFacet2]
        
        XCTAssertEqual(filterBuilder.build(), """
        ( "category":"chair" OR "category":"table" ) AND "_tags":"Tom" AND "price" > 10.0
        """)

        filterBuilder[.and("b")] +++ [filterNumeric1, filterNumeric2]
        
        XCTAssertEqual(filterBuilder.build(), """
        ( "category":"chair" OR "category":"table" ) AND "_tags":"Tom" AND "price" < 20.0 AND "price" > 10.0
        """)
        
    }
    
    func testAndGroupSubscript() {
        let filterBuilder = FilterBuilder()
        
        let filter = FilterFacet(attribute: "category", value: "table")
        
        let group = AndFilterGroup(name: "group")
        
        filterBuilder[group] +++ filter

        XCTAssertTrue(filterBuilder.contains(filter))
        
        XCTAssertEqual(filterBuilder.build(), """
        "category":"table"
        """)

    }
    
    func testOrGroupSubscript() {
        let filterBuilder = FilterBuilder()
        
        let filter = FilterFacet(attribute: "category", value: "table")
        
        let group = OrFilterGroup<FilterFacet>(name: "group")

        filterBuilder[group] +++ filter
        
        XCTAssertTrue(filterBuilder.contains(filter))
        
        XCTAssertEqual(filterBuilder.build(), """
        "category":"table"
        """)
    }
    
    func testOrGroupAddAll() {
        let filterBuilder = FilterBuilder()
        let group = OrFilterGroup<FilterFacet>(name: "group")
        let filter1 = FilterFacet(attribute: "category", value: "table")
        let filter2 = FilterFacet(attribute: "category", value: "chair")
        filterBuilder.addAll([filter1, filter2], to: group)
        XCTAssertTrue(filterBuilder.contains(filter1))
        XCTAssertTrue(filterBuilder.contains(filter2))
        
        XCTAssertEqual(filterBuilder.build(), """
        ( "category":"chair" OR "category":"table" )
        """)
    }
    
    func testAndGroupAddAll() {
        let filterBuilder = FilterBuilder()
        let group = AndFilterGroup(name: "group")
        let filterPrice = FilterNumeric(attribute: "price", operator: .greaterThan, value: 10)
        let filterSize = FilterNumeric(attribute: "size", operator: .greaterThan, value: 20)
        filterBuilder.addAll([filterPrice, filterSize], to: group)
        XCTAssertTrue(filterBuilder.contains(filterPrice))
        XCTAssertTrue(filterBuilder.contains(filterSize))
        
        XCTAssertEqual(filterBuilder.build(), """
        "price" > 10.0 AND "size" > 20.0
        """)
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
        XCTAssertEqual(filterBuilder.build(), """
        ( "price" < 20.0 OR "price" > 10.0 )
        """)
        
        filterBuilder.addAll([filterTag1, filterTag2], to: groupTagsOr)
        
        XCTAssertEqual(filterBuilder.build(), """
        ( "price" < 20.0 OR "price" > 10.0 ) AND ( "_tags":"Hank" OR "_tags":"Tom" )
        """)

        filterBuilder.removeAll(for: "price")
        
        XCTAssertFalse(filterBuilder.contains(filterNumeric1))
        XCTAssertFalse(filterBuilder.contains(filterNumeric2))
        XCTAssertTrue(filterBuilder.contains(filterTag1))
        XCTAssertTrue(filterBuilder.contains(filterTag2))
        
        XCTAssertEqual(filterBuilder.build(), """
        ( "_tags":"Hank" OR "_tags":"Tom" )
        """)
        
    }
    
    func testIsEmpty() {
        let filterBuilder = FilterBuilder()
        let filter = FilterNumeric(attribute: "price", operator: .greaterThan, value: 10)
        let group = OrFilterGroup<FilterNumeric>(name: "group")
        XCTAssertTrue(filterBuilder.isEmpty)
        filterBuilder.add(filter, to: group)
        XCTAssertEqual(filterBuilder.build(), """
        "price" > 10.0
        """)
        XCTAssertFalse(filterBuilder.isEmpty)
        filterBuilder.remove(filter)
        XCTAssertTrue(filterBuilder.isEmpty, filterBuilder.build() ?? "empty filter")
        XCTAssertNil(filterBuilder.build())
    }
    
    func testClear() {
        let filterBuilder = FilterBuilder()
        let filterNumeric = FilterNumeric(attribute: "price", operator: .greaterThan, value: 10)
        let filterTag = FilterTag(value: "Tom")
        let group = AndFilterGroup(name: "group")
        filterBuilder.add(filterNumeric, to: group)
        XCTAssertEqual(filterBuilder.build(), """
        "price" > 10.0
        """)
        filterBuilder.add(filterTag, to: group)
        XCTAssertEqual(filterBuilder.build(), """
        "_tags":"Tom" AND "price" > 10.0
        """)
        filterBuilder.removeAll()
        XCTAssertTrue(filterBuilder.isEmpty)
        XCTAssertNil(filterBuilder.build())
    }
    
    func testAndGroupOperators() {
        
        let filterBuilder = FilterBuilder()
        
        filterBuilder[.and("g")] +++ "tag1"
        
        XCTAssertEqual(filterBuilder.build(), """
        "_tags":"tag1"
        """)
        
        XCTAssertTrue(filterBuilder.contains(FilterTag(value:"tag1")))
        
        filterBuilder[.and("g")] +++ [FilterTag(value:"tag2"), FilterTag(value:"tag3")]
        
        XCTAssertEqual(filterBuilder.build(), """
        "_tags":"tag1" AND "_tags":"tag2" AND "_tags":"tag3"
        """)
        
        XCTAssertTrue(filterBuilder.contains(FilterTag(value:"tag2")))
        XCTAssertTrue(filterBuilder.contains(FilterTag(value:"tag3")))

        filterBuilder[.and("g")] +++ ("price", .greaterThan, 100)
        
        XCTAssertEqual(filterBuilder.build(), """
        "_tags":"tag1" AND "_tags":"tag2" AND "_tags":"tag3" AND "price" > 100.0
        """)
        
        XCTAssertTrue(filterBuilder.contains(FilterNumeric(attribute: "price", operator: .greaterThan, value: 100)))
        
        filterBuilder[.and("g")] +++ ("size", 30...40)
        
        XCTAssertEqual(filterBuilder.build(), """
        "_tags":"tag1" AND "_tags":"tag2" AND "_tags":"tag3" AND "price" > 100.0 AND "size":30.0 TO 40.0
        """)
        
        XCTAssertTrue(filterBuilder.contains(FilterNumeric(attribute: "size", range: 30...40)))
        
        filterBuilder[.and("g")] +++ ("brand", "sony")
        
        XCTAssertEqual(filterBuilder.build(), """
        "_tags":"tag1" AND "_tags":"tag2" AND "_tags":"tag3" AND "brand":"sony" AND "price" > 100.0 AND "size":30.0 TO 40.0
        """)
        
        XCTAssertTrue(filterBuilder.contains(FilterFacet(attribute: "brand", value: "sony")))

        filterBuilder[.and("g")] --- "tag1"
        
        XCTAssertEqual(filterBuilder.build(), """
        "_tags":"tag2" AND "_tags":"tag3" AND "brand":"sony" AND "price" > 100.0 AND "size":30.0 TO 40.0
        """)
        
        XCTAssertFalse(filterBuilder.contains(FilterTag(value:"tag1")))
        
        filterBuilder[.and("g")] --- [FilterTag(value:"tag2"), FilterTag(value:"tag3")]
        
        XCTAssertEqual(filterBuilder.build(), """
        "brand":"sony" AND "price" > 100.0 AND "size":30.0 TO 40.0
        """)
        
        XCTAssertFalse(filterBuilder.contains(FilterTag(value:"tag2")))
        XCTAssertFalse(filterBuilder.contains(FilterTag(value:"tag3")))

        filterBuilder[.and("g")] --- ("price", .greaterThan, 100)
        
        XCTAssertEqual(filterBuilder.build(), """
        "brand":"sony" AND "size":30.0 TO 40.0
        """)
        
        XCTAssertFalse(filterBuilder.contains(FilterNumeric(attribute: "price", operator: .greaterThan, value: 100)))

        filterBuilder[.and("g")] --- ("size", 30...40)
        
        XCTAssertEqual(filterBuilder.build(), """
        "brand":"sony"
        """)
        
        XCTAssertFalse(filterBuilder.contains(FilterNumeric(attribute: "size", range: 30...40)))

        filterBuilder[.and("g")] --- ("brand", "sony")
        
        XCTAssertNil(filterBuilder.build())

        XCTAssertFalse(filterBuilder.contains(FilterFacet(attribute: "brand", value: "sony")))

    }
    
    func testOrGroupOperators() {
        
        let filterBuilder = FilterBuilder()
        
        let tagGroup = OrFilterGroup<FilterTag>(name: "g1")
        let facetGroup = OrFilterGroup<FilterFacet>(name: "g2")
        let numericGroup = OrFilterGroup<FilterNumeric>(name: "g3")
        
        filterBuilder[tagGroup] +++ "tag1"
        
        XCTAssertEqual(filterBuilder.build(), """
        "_tags":"tag1"
        """)
        
        XCTAssertTrue(filterBuilder.contains(FilterTag(value: "tag1")))
        
        filterBuilder[tagGroup] +++ [FilterTag(value: "tag2"), FilterTag(value: "tag3")]
        
        XCTAssertEqual(filterBuilder.build(), """
        ( "_tags":"tag1" OR "_tags":"tag2" OR "_tags":"tag3" )
        """)
        
        XCTAssertTrue(filterBuilder.contains(FilterTag(value: "tag2")))
        XCTAssertTrue(filterBuilder.contains(FilterTag(value: "tag3")))

        filterBuilder[facetGroup] +++ ("brand", "sony")
        
        XCTAssertEqual(filterBuilder.build(), """
        ( "_tags":"tag1" OR "_tags":"tag2" OR "_tags":"tag3" ) AND "brand":"sony"
        """)

        XCTAssertTrue(filterBuilder.contains(FilterFacet(attribute: "brand", value: "sony")))
        
        filterBuilder[numericGroup] +++ ("price", .greaterThan, 100)
        
        XCTAssertEqual(filterBuilder.build(), """
        ( "_tags":"tag1" OR "_tags":"tag2" OR "_tags":"tag3" ) AND "brand":"sony" AND "price" > 100.0
        """)
        
        XCTAssertTrue(filterBuilder.contains(FilterNumeric(attribute: "price", operator: .greaterThan, value: 100)))
        
        filterBuilder[numericGroup] +++ ("size", 30...40)
        
        XCTAssertEqual(filterBuilder.build(), """
        ( "_tags":"tag1" OR "_tags":"tag2" OR "_tags":"tag3" ) AND "brand":"sony" AND ( "price" > 100.0 OR "size":30.0 TO 40.0 )
        """)
        
        XCTAssertTrue(filterBuilder.contains(FilterNumeric(attribute: "size", range: 30...40)))
        
        filterBuilder[tagGroup] --- "tag1"
        
        XCTAssertEqual(filterBuilder.build(), """
        ( "_tags":"tag2" OR "_tags":"tag3" ) AND "brand":"sony" AND ( "price" > 100.0 OR "size":30.0 TO 40.0 )
        """)
        
        XCTAssertFalse(filterBuilder.contains(FilterTag(value: "tag1")))
        
        filterBuilder[tagGroup] --- [FilterTag(value: "tag2"), FilterTag(value: "tag3")]
        
        XCTAssertEqual(filterBuilder.build(), """
        "brand":"sony" AND ( "price" > 100.0 OR "size":30.0 TO 40.0 )
        """)
        
        XCTAssertFalse(filterBuilder.contains(FilterTag(value: "tag2")))
        XCTAssertFalse(filterBuilder.contains(FilterTag(value: "tag3")))

        filterBuilder[facetGroup] --- ("brand", "sony")
        
        XCTAssertEqual(filterBuilder.build(), """
        ( "price" > 100.0 OR "size":30.0 TO 40.0 )
        """)
        
        XCTAssertFalse(filterBuilder.contains(FilterFacet(attribute: "brand", value: "sony")))

        filterBuilder[numericGroup] --- ("price", .greaterThan, 100)
        
        XCTAssertEqual(filterBuilder.build(), """
        "size":30.0 TO 40.0
        """)
        
        XCTAssertFalse(filterBuilder.contains(FilterNumeric(attribute: "price", operator: .greaterThan, value: 100)))

        filterBuilder[numericGroup] --- ("size", 30...40)
        
        XCTAssertNil(filterBuilder.build())
        
        XCTAssertFalse(filterBuilder.contains(FilterNumeric(attribute: "price", range: 30...40)))
        
        XCTAssertTrue(filterBuilder.isEmpty)
        
    }
    
    func testDisjunctiveFacetAttributes() {
        
        let filterBuilder = FilterBuilder()
        
        filterBuilder[.or("g1")]
            +++ ("color", "red")
            +++ ("color", "green")
            +++ ("color", "blue")
        
        XCTAssertEqual(filterBuilder.disjunctiveFacetsAttributes(), ["color"])
        
        filterBuilder[.or("g2")]
            +++ ("country", "france")
        
        XCTAssertEqual(filterBuilder.disjunctiveFacetsAttributes(), ["color", "country"])

        filterBuilder[.or("g2")]
            +++ ("country", "uk")
        
        filterBuilder[.or("g2")]
            +++ ("size", 40)
        
        XCTAssertEqual(filterBuilder.disjunctiveFacetsAttributes(), ["color", "country", "size"])
        
        filterBuilder[.and("g3")]
            +++ ("price", .greaterThan, 50)
            +++ ("featured", true)
        
        XCTAssertEqual(filterBuilder.disjunctiveFacetsAttributes(), ["color", "country", "size"])

        filterBuilder[.and("g3")]
            +++ ("price", .lessThan, 100)
        
        XCTAssertEqual(filterBuilder.disjunctiveFacetsAttributes(), ["color", "country", "size"])
        
        filterBuilder[.or("g2")]
            +++ ("size", 42)
        
        XCTAssertEqual(filterBuilder.disjunctiveFacetsAttributes(), ["color", "country", "size"])
        
        filterBuilder[.or("g1")]
            --- ("color", "red")
            --- ("color", "green")
            --- ("color", "blue")
        
        XCTAssertEqual(filterBuilder.disjunctiveFacetsAttributes(), ["country", "size"])

    }
    
    func testRefinements() {
        
        let filterBuilder = FilterBuilder()
    
        filterBuilder[.or("g1")]
            +++ ("color", "red")
            +++ ("color", "green")
            +++ ("color", "blue")
        
        XCTAssertEqual(filterBuilder.refinements()["color"], ["red", "green", "blue"])

        filterBuilder[.or("g2")]
            +++ ("country", "france")

        XCTAssertEqual(filterBuilder.refinements()["color"], ["red", "green", "blue"])
        XCTAssertEqual(filterBuilder.refinements()["country"], ["france"])
        
        filterBuilder[.and("g3")]
            +++ ("country", "uk")
        
        XCTAssertEqual(filterBuilder.refinements()["color"], ["red", "green", "blue"])
        XCTAssertEqual(filterBuilder.refinements()["country"], ["france", "uk"])

        filterBuilder[.or("g1")]
            --- ("color", "green")

        XCTAssertEqual(filterBuilder.refinements()["color"], ["red", "blue"])
        XCTAssertEqual(filterBuilder.refinements()["country"], ["france", "uk"])

    }
    
    func testToggle() {
        
        let filterBuilder = FilterBuilder()
        
        let filter = FilterFacet(attribute: "brand", stringValue: "sony")
        
        // Conjunctive Group
        
        XCTAssertFalse(filterBuilder[.or("a")].contains(filter))
        XCTAssertTrue(filterBuilder[.or("a", ofType: FilterFacet.self)].isEmpty)

        filterBuilder[.or("a")].toggle(filter)
        XCTAssertTrue(filterBuilder[.or("a")].contains(filter))
        XCTAssertFalse(filterBuilder[.or("a", ofType: FilterFacet.self)].isEmpty)

        filterBuilder[.or("a")].toggle(filter)
        XCTAssertFalse(filterBuilder[.or("a")].contains(filter))
        XCTAssertTrue(filterBuilder[.or("a", ofType: FilterFacet.self)].isEmpty)

        // Disjunctive Group

        XCTAssertFalse(filterBuilder[.and("a")].contains(filter))
        XCTAssertTrue(filterBuilder[.and("a")].isEmpty)

        filterBuilder[.and("a")].toggle(filter)
        XCTAssertTrue(filterBuilder[.and("a")].contains(filter))
        XCTAssertFalse(filterBuilder[.and("a")].isEmpty)

        filterBuilder[.and("a")].toggle(filter)
        XCTAssertFalse(filterBuilder[.and("a")].contains(filter))
        XCTAssertTrue(filterBuilder[.and("a")].isEmpty)
        
        filterBuilder[.and("a")] <> ("size", .equals, 40) <> ("country", "france")
        
        XCTAssertFalse(filterBuilder[.and("a")].isEmpty)
        XCTAssertTrue(filterBuilder[.and("a")].contains(FilterNumeric(attribute: "size", operator: .equals, value: 40)))
        XCTAssertTrue(filterBuilder[.and("a")].contains(FilterFacet(attribute: "country", stringValue: "france")))
        
        filterBuilder[.and("a")] <> ("size", .equals, 40) <> ("country", "france")

        XCTAssertTrue(filterBuilder[.and("a")].isEmpty)
        XCTAssertFalse(filterBuilder[.and("a")].contains(FilterNumeric(attribute: "size", operator: .equals, value: 40)))
        XCTAssertFalse(filterBuilder[.and("a")].contains(FilterFacet(attribute: "country", stringValue: "france")))

        
        filterBuilder[.or("a")] <> ("size", 40) <> ("count", 25)
        
        XCTAssertFalse(filterBuilder[.or("a", ofType: FilterFacet.self)].isEmpty)
        XCTAssertTrue(filterBuilder[.or("a", ofType: FilterFacet.self)].contains(FilterFacet(attribute: "size", floatValue: 40)))
        XCTAssertTrue(filterBuilder[.or("a", ofType: FilterFacet.self)].contains(FilterFacet(attribute: "count", floatValue: 25)))

        
    }

}
