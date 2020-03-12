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
            
    do {
      let creation = try index.saveObject(record: object)
      _ = try index.wait(for: creation)
      let object: JSON = try index.getObject(objectID: creation.objectID)
      print(object)
    } catch let error {
      XCTFail("\(error)")
    }
    
    
  }
  
  func testSaveGetObjectCallback() {
    
    let object: JSON = [
      "testField1": "testValue1",
      "testField2": 2,
      "testField3": true]
    
    let expectation = self.expectation(description: "Save-Wait-Create")
    
    index.saveObject(record: object) { result in
      switch result {
      case .failure(let error):
        XCTFail("\(error)")

      case .success(let creation):
        self.index.waitTask(withID: creation.taskID) { result in
          switch result {
          case .failure(let error):
            XCTFail("\(error)")

          case .success:
            self.index.getObject(objectID: creation.objectID) { (result: Result<JSON, Error>) in
              switch result {
              case .failure(let error):
                XCTFail("\(error)")
                
              case .success(let object):
                print(object)
                expectation.fulfill()
              }
            }
          }
        }
      }
    }
    
    waitForExpectations(timeout: expectationTimeout, handler: .none)
    
  }
  
}


