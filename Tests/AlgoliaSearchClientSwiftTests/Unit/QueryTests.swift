//
//  QueryTests.swift
//  
//
//  Created by Vladislav Fitc on 09/04/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class QueryTests: XCTestCase {
  
  func testStringEncoding() {
    let _ = Query("testQuery").set(\.typoTolerance, to: .strict).set(\.ignorePlurals, to: .false)    
  }

}
