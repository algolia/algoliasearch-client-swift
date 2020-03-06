//
//  IndexingIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 05/03/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class IndexingIntegrationTests: OnlineTestCase {
  
  func testSaveGetObject() {
    
    let object: JSON = [
      "testField1": "testValue1",
      "testField2": 2,
      "testField3": true]
    
    index.saveObject(record: object) { result in
      switch result {
      case .failure(let error):
        XCTFail("\(error)")
      case .success(let creation):
        print(creation)
      }
    }
    
    
  }
  
}
