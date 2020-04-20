//
//  SearchIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 10.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class SearchIntegrationTests: OnlineTestCase {

  func testSearch() throws {

    let employeesData = try Data(filename: "Employees.json")
    let employees = try JSONDecoder().decode([JSON].self, from: employeesData)

    var settings = Settings()
    settings.attributesForFaceting = [.searchable("company")]

      let setSettingsTask = try index.setSettings(settings)
      _ = try setSettingsTask.wait()
      let saveTask = try index.saveObjects(employees)
      _ = try saveTask.wait()
      let results = try index.search(query: "algolia")

      XCTAssertEqual(results.nbHits, 2)
      XCTAssertEqual(results.hits.firstIndex { $0.objectID ==  "nicolas-dessaigne"}, 0)
      XCTAssertEqual(results.hits.firstIndex { $0.objectID ==  "julien-lemoine"}, 1)

  }

}
