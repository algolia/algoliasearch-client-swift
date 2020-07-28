//
//  SearchIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 10.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class SearchIntegrationTests: OnlineTestCase {
  
  override var retryableTests: [() throws -> Void] {
    [search]
  }

  func search() throws {
    
    let employeesData = try Data(filename: "Employees.json")
    let employees = try JSONDecoder().decode([JSON].self, from: employeesData)

    let settings = Settings().set(\.attributesForFaceting, to: [.searchable("company")])
    try index.setSettings(settings).wait()
    try index.saveObjects(employees, autoGeneratingObjectID: true).wait()
    
    var results = try index.search(query: "algolia")
    XCTAssertEqual(results.nbHits, 2)
    XCTAssertEqual(results.hits.firstIndex { $0.objectID ==  "nicolas-dessaigne"}, 0)
    XCTAssertEqual(results.hits.firstIndex { $0.objectID ==  "julien-lemoine"}, 1)
    XCTAssertNil(results.hits.firstIndex { $0.objectID ==  ""})

    var foundObject = try index.findObject(matching: { (_: JSON) in return false }, for: "", paginate: true, requestOptions: .none)
    XCTAssertNil(foundObject)
    
    foundObject = try index.findObject(matching: { (_: JSON) in return true }, for: "", paginate: true, requestOptions: .none)
    XCTAssertEqual(foundObject?.page, 0)
    XCTAssertEqual(foundObject?.position, 0)
    
    foundObject = try index.findObject(matching: { (value: JSON) in value["company"] == "Apple" }, for: "algolia", paginate: true, requestOptions: .none)
    XCTAssertNil(foundObject)

    foundObject = try index.findObject(matching: { (value: JSON) in value["company"] == "Apple" }, for: Query.empty.set(\.hitsPerPage, to: 5), paginate: false, requestOptions: .none)
    XCTAssertNil(foundObject)

    foundObject = try index.findObject(matching: { (value: JSON) in value["company"] == "Apple" }, for: Query.empty.set(\.hitsPerPage, to: 5), paginate: true, requestOptions: .none)
    XCTAssertEqual(foundObject?.page, 2)
    XCTAssertEqual(foundObject?.position, 0)
    
    results = try index.search(query: ("elon" as Query).set(\.clickAnalytics, to: true))
    XCTAssertNotNil(results.queryID)
    
    results = try index.search(query: ("elon" as Query).set(\.facets, to: ["*"]).set(\.filters, to: "company:tesla"))
    XCTAssertEqual(results.nbHits, 1)
    
    results = try index.search(query: ("elon" as Query).set(\.facets, to: ["*"]).set(\.filters, to: "(company:tesla OR company:spacex)"))
    XCTAssertEqual(results.nbHits, 2)
    
    let facetResults = try index.searchForFacetValues(of: "company", matching: "a")
    XCTAssertEqual(Set(facetResults.facetHits.map(\.value)), ["Algolia", "Amazon", "Apple", "Arista Networks"])
    
  }

}
