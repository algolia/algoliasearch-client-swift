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
  
  func testSearch() {
    
    guard case .array(let companies) = try? JSON(jsonString: Resource.companies) else {
      XCTFail()
      return
    }
  
    var settings = Settings()
    settings.attributesForFaceting = [.searchable("company")]

    do {
      
      let setSettingsTask = try index.setSettings(settings)
      _ = try index.wait(for: setSettingsTask)
      for company in companies {
        let saveTask = try index.saveObject(record: company)
        _ = try index.wait(for: saveTask)
      }
      
      let results = try index.search(query: "algolia")
      
      XCTAssertEqual(results.nbHits, 2)
      XCTAssertEqual(results.hits.firstIndex { $0.objectID ==  "nicolas-dessaigne"}, 0)
      XCTAssertEqual(results.hits.firstIndex { $0.objectID ==  "julien-lemoine"}, 1)
      
    } catch let error {
      XCTFail("\(error)")
    }
        
  }
  
}


