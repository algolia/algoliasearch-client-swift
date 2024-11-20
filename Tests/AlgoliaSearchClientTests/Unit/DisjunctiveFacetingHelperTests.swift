//
//  DisjunctiveFacetingHelperTests.swift
//
//
//  Created by Vladislav Fitc on 20/03/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class DisjunctiveFacetingHelperTests: XCTestCase {
  
  func testBuildFilters() throws {
    let refinements: [Attribute: [String]] = [
      "size": ["m", "s"],
      "color": ["blue", "green", "red"],
      "brand": ["apple", "samsung", "sony"]
    ]
    
    let disjunctiveFacets: Set<Attribute> = [
      "color"
    ]
    
    let helper = DisjunctiveFacetingHelper(query: Query(),
                                           refinements: refinements,
                                           disjunctiveFacets: disjunctiveFacets)
    
    XCTAssertEqual(helper.buildFilters(excluding: .none), """
    ("brand":"apple" AND "brand":"samsung" AND "brand":"sony") AND ("color":"blue" OR "color":"green" OR "color":"red") AND ("size":"m" AND "size":"s")
    """)
    XCTAssertEqual(helper.buildFilters(excluding: "popularity"), """
    ("brand":"apple" AND "brand":"samsung" AND "brand":"sony") AND ("color":"blue" OR "color":"green" OR "color":"red") AND ("size":"m" AND "size":"s")
    """)
    XCTAssertEqual(helper.buildFilters(excluding: "brand"), """
    ("color":"blue" OR "color":"green" OR "color":"red") AND ("size":"m" AND "size":"s")
    """)
    XCTAssertEqual(helper.buildFilters(excluding: "color"), """
    ("brand":"apple" AND "brand":"samsung" AND "brand":"sony") AND ("size":"m" AND "size":"s")
    """)
    XCTAssertEqual(helper.buildFilters(excluding: "size"), """
    ("brand":"apple" AND "brand":"samsung" AND "brand":"sony") AND ("color":"blue" OR "color":"green" OR "color":"red")
    """)
  }
  
  func testAppliedDisjunctiveFacetValues() {
    let refinements: [Attribute: [String]] = [
      "size": ["m", "s"],
      "color": ["blue", "green", "red"],
      "brand": ["apple", "samsung", "sony"]
    ]

    let disjunctiveFacets: Set<Attribute> = [
      "color",
      "brand"
    ]
    
    let helper = DisjunctiveFacetingHelper(query: Query(),
                                           refinements: refinements,
                                           disjunctiveFacets: disjunctiveFacets)
    
    XCTAssertTrue(helper.appliedDisjunctiveFacetValues(for: "popularity").isEmpty)
    XCTAssertTrue(helper.appliedDisjunctiveFacetValues(for: "size").isEmpty)
    XCTAssertEqual(helper.appliedDisjunctiveFacetValues(for: "color"), ["red", "green", "blue"])
    XCTAssertEqual(helper.appliedDisjunctiveFacetValues(for: "brand"), ["samsung", "sony", "apple"])
  }
  
  func testMakeQueriesNoDisjunctive() {
    let refinements: [Attribute: [String]] = [
      "size": ["m", "s"],
      "color": ["blue", "green", "red"],
      "brand": ["apple", "samsung", "sony"]
    ]

    let helper = DisjunctiveFacetingHelper(query: Query(),
                                           refinements: refinements,
                                           disjunctiveFacets: [])
    let queries = helper.makeQueries()
    XCTAssertEqual(queries.count, 1)
    XCTAssertEqual(queries.first?.filters, """
    ("brand":"apple" AND "brand":"samsung" AND "brand":"sony") AND ("color":"blue" AND "color":"green" AND "color":"red") AND ("size":"m" AND "size":"s")
    """)
  }
  
  func testMakeQueriesDisjunctiveSingle() {
    let refinements: [Attribute: [String]] = [
      "size": ["m", "s"],
      "color": ["blue", "green", "red"],
      "brand": ["apple", "samsung", "sony"]
    ]

    let helper = DisjunctiveFacetingHelper(query: Query(),
                                           refinements: refinements,
                                           disjunctiveFacets: ["color"])
    let queries = helper.makeQueries()
    XCTAssertEqual(queries.count, 2)
    XCTAssertEqual(queries.first?.filters, """
    ("brand":"apple" AND "brand":"samsung" AND "brand":"sony") AND ("color":"blue" OR "color":"green" OR "color":"red") AND ("size":"m" AND "size":"s")
    """)
    XCTAssertEqual(queries.last?.facets, ["color"])
    XCTAssertEqual(queries.last?.filters, """
    ("brand":"apple" AND "brand":"samsung" AND "brand":"sony") AND ("size":"m" AND "size":"s")
    """)
  }
  
  func testMakeQueriesDisjunctiveDouble() {
    let refinements: [Attribute: [String]] = [
      "size": ["m", "s"],
      "color": ["blue", "green", "red"],
      "brand": ["apple", "samsung", "sony"]
    ]
    let disjunctiveFacets: Set<Attribute> = [
      "color",
      "size"
    ]
    let helper = DisjunctiveFacetingHelper(query: Query(),
                                           refinements: refinements,
                                           disjunctiveFacets: disjunctiveFacets)
    let queries = helper.makeQueries()
    XCTAssertEqual(queries.count, 3)
    XCTAssertEqual(queries.first?.filters, """
    ("brand":"apple" AND "brand":"samsung" AND "brand":"sony") AND ("color":"blue" OR "color":"green" OR "color":"red") AND ("size":"m" OR "size":"s")
    """)
    XCTAssertEqual(queries[1].facets, ["color"])
    XCTAssertEqual(queries[1].filters, """
    ("brand":"apple" AND "brand":"samsung" AND "brand":"sony") AND ("size":"m" OR "size":"s")
    """)
    XCTAssertEqual(queries[2].facets, ["size"])
    XCTAssertEqual(queries[2].filters, """
    ("brand":"apple" AND "brand":"samsung" AND "brand":"sony") AND ("color":"blue" OR "color":"green" OR "color":"red")
    """)
  }
  
  func testMergeEmptyResponses() {
    let refinements: [Attribute: [String]] = [
      "size": ["m", "s"],
      "color": ["blue", "green", "red"],
      "brand": ["apple", "samsung", "sony"]
    ]
    let disjunctiveFacets: Set<Attribute> = [
      "color",
      "size"
    ]
    let helper = DisjunctiveFacetingHelper(query: Query(),
                                           refinements: refinements,
                                           disjunctiveFacets: disjunctiveFacets)
    
    XCTAssertThrowsError(try helper.mergeResponses([]))
  }
  
  func testMergeDisjunctiveSingle() throws {
    let refinements: [Attribute: [String]] = [
      "size": ["m", "s"],
      "color": ["blue", "green", "red"],
      "brand": ["apple", "samsung", "sony"]
    ]
    let disjunctiveFacets: Set<Attribute> = [
      "color"
    ]
    let helper = DisjunctiveFacetingHelper(query: Query(),
                                           refinements: refinements,
                                           disjunctiveFacets: disjunctiveFacets)
    var mainResponse = SearchResponse()
    mainResponse.facets = [
      "size": [
        Facet(value: "s", count: 5),
        Facet(value: "m", count: 7),
      ],
      "color": [
        Facet(value: "red", count: 1),
        Facet(value: "green", count: 2),
        Facet(value: "blue", count: 3),
      ],
      "brand": [
        Facet(value: "samsung", count: 5),
        Facet(value: "sony", count: 10),
        Facet(value: "apple", count: 15),
      ],
    ]
    var disjunctiveResponse = SearchResponse()
    disjunctiveResponse.facets = [
      "color": [
        Facet(value: "red", count: 10),
        Facet(value: "green", count: 20),
        Facet(value: "blue", count: 30),
      ]
    ]
    let response = try helper.mergeResponses([
      mainResponse,
      disjunctiveResponse,
    ])
    XCTAssertEqual(response.facets, [
      "size": [
        Facet(value: "s", count: 5),
        Facet(value: "m", count: 7),
      ],
      "color": [
        Facet(value: "red", count: 1),
        Facet(value: "green", count: 2),
        Facet(value: "blue", count: 3),
      ],
      "brand": [
        Facet(value: "samsung", count: 5),
        Facet(value: "sony", count: 10),
        Facet(value: "apple", count: 15),
      ],
    ])
    XCTAssertEqual(response.disjunctiveFacets, ["color": [
      Facet(value: "red", count: 10),
      Facet(value: "green", count: 20),
      Facet(value: "blue", count: 30),
    ]])
  }
  
  func testMergeDisjunctiveDouble() throws {
    let refinements: [Attribute: [String]] = [
      "size": ["m", "s"],
      "color": ["blue", "green", "red"],
      "brand": ["apple", "samsung", "sony"]
    ]
    let disjunctiveFacets: Set<Attribute> = [
      "color",
      "size"
    ]
    let helper = DisjunctiveFacetingHelper(query: Query(),
                                           refinements: refinements,
                                           disjunctiveFacets: disjunctiveFacets)
    var mainResponse = SearchResponse()
    mainResponse.facets = [
      "size": [
        Facet(value: "s", count: 5),
        Facet(value: "m", count: 7),
      ],
      "color": [
        Facet(value: "red", count: 1),
        Facet(value: "green", count: 2),
        Facet(value: "blue", count: 3),
      ],
      "brand": [
        Facet(value: "samsung", count: 5),
        Facet(value: "sony", count: 10),
        Facet(value: "apple", count: 15),
      ],
    ]
    var firstDisjunctiveResponse = SearchResponse()
    firstDisjunctiveResponse.facets = [
      "color": [
        Facet(value: "red", count: 10),
        Facet(value: "green", count: 20),
        Facet(value: "blue", count: 30),
      ]
    ]
    var secondDisjunctiveResponse = SearchResponse()
    secondDisjunctiveResponse.facets = [
      "size": [
        Facet(value: "s", count: 3),
        Facet(value: "m", count: 4),
      ]
    ]
    let response = try helper.mergeResponses([
      mainResponse,
      firstDisjunctiveResponse,
      secondDisjunctiveResponse,
    ])
    XCTAssertEqual(response.facets, [
      "size": [
        Facet(value: "s", count: 5),
        Facet(value: "m", count: 7),
      ],
      "color": [
        Facet(value: "red", count: 1),
        Facet(value: "green", count: 2),
        Facet(value: "blue", count: 3),
      ],
      "brand": [
        Facet(value: "samsung", count: 5),
        Facet(value: "sony", count: 10),
        Facet(value: "apple", count: 15),
      ],
    ])
    XCTAssertEqual(response.disjunctiveFacets, [
      "color": [
        Facet(value: "red", count: 10),
        Facet(value: "green", count: 20),
        Facet(value: "blue", count: 30),
      ],
      "size": [
        Facet(value: "s", count: 3),
        Facet(value: "m", count: 4),
      ],
    ])
  }
  
  func testMergeFacetStats() throws {
    let helper = DisjunctiveFacetingHelper(query: Query(),
                                           refinements: [:],
                                           disjunctiveFacets: [])
    
    
    var mainResponse = SearchResponse()
    mainResponse.facetStats = [
      "price": FacetStats(min: 5, max: 100, avg: 52.5, sum: 2400),
      "target": FacetStats(min: 1, max: 10, avg: 5.5, sum: 43)
    ]
    var firstDisjunctiveResponse = SearchResponse()
    firstDisjunctiveResponse.facetStats = [
      "price": FacetStats(min: 7, max: 103, avg: 55, sum: 3000),
      "note": FacetStats(min: 1, max: 5, avg: 3, sum: 37)
    ]
    var secondDisjunctiveResponse = SearchResponse()
    secondDisjunctiveResponse.facetStats = [
      "size": FacetStats(min: 20, max: 56, avg: 38, sum: 242)
    ]
    let response = try helper.mergeResponses([
      mainResponse,
      firstDisjunctiveResponse,
      secondDisjunctiveResponse,
    ])
    
    
    XCTAssertEqual(response.facetStats?.count, 4)
    assertEqual(response.facetStats?["price"], FacetStats(min: 7, max: 103, avg: 55, sum: 3000),
                file: #filePath,
                line: #line)
    assertEqual(response.facetStats?["target"], FacetStats(min: 1, max: 10, avg: 5.5, sum: 43),
                file: #filePath,
                line: #line)
    assertEqual(response.facetStats?["size"], FacetStats(min: 20, max: 56, avg: 38, sum: 242),
                file: #filePath,
                line: #line)
    assertEqual(response.facetStats?["note"], FacetStats(min: 1, max: 5, avg: 3, sum: 37),
                file: #filePath,
                line: #line)
  }
  
  func assertEqual(_ lhs: FacetStats?, _ rhs: FacetStats?, file: StaticString = #filePath, line: UInt = #line) {
    guard let lhs = lhs else {
      XCTAssertNil(rhs, file: file, line: line)
      return
    }
    guard let rhs = rhs else {
      XCTAssertNil(lhs, file: file, line: line)
      return
    }
    XCTAssertEqual(lhs.min, rhs.min, accuracy: 0.01, file: file, line: line)
    XCTAssertEqual(lhs.max, rhs.max, accuracy: 0.01, file: file, line: line)
    if let lAvg = lhs.avg, let rAvg = rhs.avg {
      XCTAssertEqual(lAvg, rAvg, accuracy: 0.01, file: file, line: line)
    } else {
      XCTAssertEqual(lhs.avg, rhs.avg, file: file, line: line)
    }
    if let lSum = lhs.sum, let rSum = rhs.sum {
      XCTAssertEqual(lSum, rSum, accuracy: 0.01, file: file, line: line)
    } else {
      XCTAssertEqual(lhs.sum, rhs.sum, file: file, line: line)
    }
  }
  
  func testMergeExhaustiveFacetsCount() throws {
    let helper = DisjunctiveFacetingHelper(query: Query(),
                                           refinements: [:],
                                           disjunctiveFacets: [])
    
    
    var mainResponse = SearchResponse()
    mainResponse.exhaustiveFacetsCount = true
    var firstDisjunctiveResponse = SearchResponse()
    firstDisjunctiveResponse.exhaustiveFacetsCount = true
    var secondDisjunctiveResponse = SearchResponse()
    secondDisjunctiveResponse.exhaustiveFacetsCount = false
    var response = try helper.mergeResponses([
      mainResponse,
      firstDisjunctiveResponse,
      secondDisjunctiveResponse,
    ])
    XCTAssertFalse(response.exhaustiveFacetsCount!)
    secondDisjunctiveResponse.exhaustiveFacetsCount = true
    response = try helper.mergeResponses([
      mainResponse,
      firstDisjunctiveResponse,
      secondDisjunctiveResponse,
    ])
    XCTAssertTrue(response.exhaustiveFacetsCount!)
  }
    
    func testKeepExistingFilters() throws {
        var query = Query()
        query.filters = "NOT color:blue"
        
        let refinements: [Attribute: [String]] = [
          "size": ["m", "s"],
          "color": ["blue", "green", "red"],
          "brand": ["apple", "samsung", "sony"]
        ]
        let disjunctiveFacets: Set<Attribute> = [
          "color",
          "size"
        ]
        let helper = DisjunctiveFacetingHelper(query: query,
                                               refinements: refinements,
                                               disjunctiveFacets: disjunctiveFacets)
        let queries = helper.makeQueries()
        XCTAssertEqual(queries.count, 3)
        XCTAssertEqual(queries.first?.filters, """
        NOT color:blue AND ("brand":"apple" AND "brand":"samsung" AND "brand":"sony") AND ("color":"blue" OR "color":"green" OR "color":"red") AND ("size":"m" OR "size":"s")
        """)
        XCTAssertEqual(queries[1].facets, ["color"])
        XCTAssertEqual(queries[1].filters, """
        NOT color:blue AND ("brand":"apple" AND "brand":"samsung" AND "brand":"sony") AND ("size":"m" OR "size":"s")
        """)
        XCTAssertEqual(queries[2].facets, ["size"])
        XCTAssertEqual(queries[2].filters, """
        NOT color:blue AND ("brand":"apple" AND "brand":"samsung" AND "brand":"sony") AND ("color":"blue" OR "color":"green" OR "color":"red")
        """)
    }
    
    func testKeepExistingFiltersEmpty() throws {
        var query = Query()
        query.filters = ""
        
        let refinements: [Attribute: [String]] = [
          "size": ["m", "s"],
          "color": ["blue", "green", "red"],
          "brand": ["apple", "samsung", "sony"]
        ]
        let disjunctiveFacets: Set<Attribute> = [
          "color",
          "size"
        ]
        let helper = DisjunctiveFacetingHelper(query: query,
                                               refinements: refinements,
                                               disjunctiveFacets: disjunctiveFacets)
        let queries = helper.makeQueries()
        XCTAssertEqual(queries.count, 3)
        XCTAssertEqual(queries.first?.filters, """
        ("brand":"apple" AND "brand":"samsung" AND "brand":"sony") AND ("color":"blue" OR "color":"green" OR "color":"red") AND ("size":"m" OR "size":"s")
        """)
        XCTAssertEqual(queries[1].facets, ["color"])
        XCTAssertEqual(queries[1].filters, """
        ("brand":"apple" AND "brand":"samsung" AND "brand":"sony") AND ("size":"m" OR "size":"s")
        """)
        XCTAssertEqual(queries[2].facets, ["size"])
        XCTAssertEqual(queries[2].filters, """
        ("brand":"apple" AND "brand":"samsung" AND "brand":"sony") AND ("color":"blue" OR "color":"green" OR "color":"red")
        """)
    }
    
    func testKeepExistingFiltersNoRefinement() throws {
        var query = Query()
        query.filters = "NOT color:blue"

        let disjunctiveFacets: Set<Attribute> = [
          "color",
          "size"
        ]
        let helper = DisjunctiveFacetingHelper(query: query,
                                               refinements: [:],
                                               disjunctiveFacets: disjunctiveFacets)
        let queries = helper.makeQueries()
        XCTAssertEqual(queries.count, 3)
        XCTAssertEqual(queries.first?.filters, """
        NOT color:blue
        """)
        XCTAssertEqual(queries[1].facets, ["color"])
        XCTAssertEqual(queries[1].filters, """
        NOT color:blue
        """)
        XCTAssertEqual(queries[2].facets, ["size"])
        XCTAssertEqual(queries[2].filters, """
        NOT color:blue
        """)
    }
}
