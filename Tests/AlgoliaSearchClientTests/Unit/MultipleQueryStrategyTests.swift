//
//  MultipleQueryStrategyTests.swift
//  
//
//  Created by Vladislav Fitc on 07/04/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class MultipleQueryStrategyTests: XCTestCase {

  func testValues() throws {
    XCTAssertEqual(MultipleQueriesStrategy.none.rawValue, "none")
    XCTAssertEqual(MultipleQueriesStrategy.stopIfEnoughMatches.rawValue, "stopIfEnoughMatches")
  }

}
