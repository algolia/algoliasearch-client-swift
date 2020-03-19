//
//  OnlineTestCase.swift
//  
//
//  Created by Vladislav Fitc on 05/03/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class OnlineTestCase: XCTestCase {
  
  var client: Client!
  var index: Index!
  let expectationTimeout: TimeInterval = 100
  
  /// Abstract base class for online test cases.
  ///
  
  override func setUp() {
    super.setUp()
    
    // Init client.
    let credentials = TestCredentials(applicationID: "", apiKey: "")
    
    let expectation = self.expectation(description: "Delete index")
    
    client = Client(appID: credentials.applicationID, apiKey: credentials.apiKey)
    
    // Init index.
    // NOTE: We use a different index name for each test function.
    let className = String(reflecting: type(of: self)).components(separatedBy: ".").last!
    let functionName = invocation!.selector.description
    let indexName = IndexName(stringLiteral: "\(className).\(functionName)")
    
    index = client.index(withName: indexName)
    
    index.delete { result in
      switch result {
      case .failure(let error):
        XCTFail("\(error)")
      case .success:
        expectation.fulfill()
      }
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
    
  }
  
  override func tearDown() {
    super.tearDown()
    
    let expectation = self.expectation(description: "Delete index")
    index.delete { result in
      switch result {
      case .failure(let error):
        XCTFail("\(error)")
      case .success:
        expectation.fulfill()
      }
    }
    waitForExpectations(timeout: expectationTimeout, handler: nil)
    
  }
  
}


