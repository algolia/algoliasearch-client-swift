//
//  RulePromotionTests.swift
//  
//
//  Created by Vladislav Fitc on 06/05/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class RulePromotionTests: XCTestCase {
  
  func testCoding() throws {
    try AssertEncodeDecode(Rule.Promotion(objectID: "o1", position: 10), ["objectID": "o1", "position": 10])
  }
  
}
