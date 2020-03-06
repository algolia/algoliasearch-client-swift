//
//  SearchTestCase.swift
//  
//
//  Created by Vladislav Fitc on 05/03/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class SearchTests: OnlineTestCase {
  
  func testSearch() {
    
    let client = Client(appID: "latency", apiKey: "af044fb0788d6bb15f807e4420592bc5")
    let index = client.index(withName: "movies")
    
    let expectation = self.expectation(description: "Search result expectation")
    
    index.search(query: "hello world") { result in
      switch result {
      case .failure(let error):
        XCTFail("\(error)")
      case .success(let result):
        print("Response: \(result.hits)")
        expectation.fulfill()
      }
    }
    
    waitForExpectations(timeout: expectationTimeout, handler: .none)
    
  }
  
}
