//
//  FilterTests.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 27/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation
import XCTest
@testable import InstantSearchClient

class FilterTests: XCTestCase {
    
    func testFilterFacetVariants() {
        testFilterFacet(with: "value")
        testFilterFacet(with: 10)
        testFilterFacet(with: true)
    }
    
    func testCopyConstructor() {
        let filterBuilder = FilterBuilder()
        filterBuilder[.and("a")] +++ ("brand", "sony") +++ ("size", 40) +++ "featured"
        filterBuilder[.or("b")] +++ "tag1" +++ "tag2" +++ "tag3"
        let filterBuilderCopy = FilterBuilder(filterBuilder)
        XCTAssertEqual(filterBuilder.groups, filterBuilderCopy.groups)
    }
    
    func testFilterFacet(with value: FilterFacet.ValueType) {
        let attribute: Attribute = "a"
        var facetFilter = FilterFacet(attribute: attribute, value: value)
        let expectedExpression = "\"\(attribute)\":\"\(value)\""
        XCTAssertEqual(facetFilter.attribute, attribute)
        XCTAssertEqual(facetFilter.expression, expectedExpression)
        XCTAssertEqual(facetFilter.build(), expectedExpression)
        XCTAssertFalse(facetFilter.isNegated)
        XCTAssertEqual(facetFilter.value, value)
        // Test inversion
        facetFilter.not()
        XCTAssertTrue(facetFilter.isNegated)
        XCTAssertEqual(facetFilter.build(), "NOT \(expectedExpression)")
    }
    
    
    func testFilterNumericComparisonConstruction() {
        let attribute: Attribute = "a"
        let value: Float = 10
        let op: FilterNumeric.NumericOperator = .equals
        let expectedExpression = """
        "\(attribute)" \(op.rawValue) \(value)
        """
        var numericFilter = FilterNumeric(attribute: attribute, operator: op, value: value)
        XCTAssertEqual(numericFilter.attribute, attribute)
        XCTAssertEqual(numericFilter.expression, expectedExpression)
        XCTAssertEqual(numericFilter.build(), expectedExpression)
        XCTAssertFalse(numericFilter.isNegated)
        // Test inversion
        numericFilter.not()
        XCTAssertTrue(numericFilter.isNegated)
        XCTAssertEqual(numericFilter.build(), "NOT \(expectedExpression)")
    }
    
    func testFilterNumericRangeConstruction() {
        let attribute: Attribute = "a"
        let value: ClosedRange<Float> = 0...10
        let expectedExpression = """
        "\(attribute)":\(value.lowerBound) TO \(value.upperBound)
        """
        var numericFilter = FilterNumeric(attribute: attribute, range: value)
        XCTAssertEqual(numericFilter.attribute, attribute)
        XCTAssertEqual(numericFilter.expression, expectedExpression)
        XCTAssertEqual(numericFilter.build(), expectedExpression)
        XCTAssertFalse(numericFilter.isNegated)
        // Test inversion
        numericFilter.not()
        XCTAssertTrue(numericFilter.isNegated)
        XCTAssertEqual(numericFilter.build(), "NOT \(expectedExpression)")
    }
    
    func testFilterTagConstruction() {
        let value = "a"
        let attribute: Attribute = .tags
        let expectedExpression =  """
        "\(attribute)":"\(value)"
        """
        var tagFilter = FilterTag(value: value)
        XCTAssertEqual(tagFilter.attribute, attribute)
        XCTAssertEqual(tagFilter.expression, expectedExpression)
        XCTAssertEqual(tagFilter.build(), expectedExpression)
        XCTAssertFalse(tagFilter.isNegated)
        // Test inversion
        tagFilter.not()
        XCTAssertTrue(tagFilter.isNegated)
        XCTAssertEqual(tagFilter.build(), "NOT \(expectedExpression)")
    }
    
    func testInversion() {
        
        let boolFacetFilter = FilterFacet(attribute: "a", value: true)
        XCTAssertFalse(boolFacetFilter.isNegated)
        XCTAssertTrue((!boolFacetFilter).isNegated)
        XCTAssertEqual(!boolFacetFilter, FilterFacet(attribute: "a", value: true, isNegated: true))
        
        let numericFacetFilter = FilterFacet(attribute: "a", value: 1)
        XCTAssertFalse(numericFacetFilter.isNegated)
        XCTAssertTrue((!numericFacetFilter).isNegated)
        XCTAssertEqual(!numericFacetFilter, FilterFacet(attribute: "a", value: 1, isNegated: true))
        
        let stringFacetFilter = FilterFacet(attribute: "a", value: "b")
        XCTAssertFalse(stringFacetFilter.isNegated)
        XCTAssertTrue((!stringFacetFilter).isNegated)
        XCTAssertEqual(!stringFacetFilter, FilterFacet(attribute: "a", value: "b", isNegated: true))
        
        let filterTag = FilterTag(value: "a")
        XCTAssertFalse(filterTag.isNegated)
        XCTAssertTrue((!filterTag).isNegated)
        XCTAssertEqual(!filterTag, FilterTag(value: "a", isNegated: true))
        
        let comparisonNumericFilter = FilterNumeric(attribute: "a", operator: .equals, value: 10)
        XCTAssertFalse(comparisonNumericFilter.isNegated)
        XCTAssertTrue((!comparisonNumericFilter).isNegated)
        XCTAssertEqual(!comparisonNumericFilter, FilterNumeric(attribute: "a", operator: .equals, value: 10, isNegated: true))
        
        let rangeNumericFilter = FilterNumeric(attribute: "a", range: 0...10)
        XCTAssertFalse(rangeNumericFilter.isNegated)
        XCTAssertTrue((!rangeNumericFilter).isNegated)
        XCTAssertEqual(!rangeNumericFilter, FilterNumeric(attribute: "a", range: 0...10, isNegated: true))
        
    }
    

}
