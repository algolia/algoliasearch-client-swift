//
//  FilterBuilderOperatorTEsts.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 22/01/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import InstantSearchClient
import XCTest

class FilterBuilderOperatorTests: XCTestCase {

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

}
