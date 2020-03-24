//
//  CustomRankingCriterionTests.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class CustomRankingCriterionTests: XCTestCase {

  func testDecoding() throws {
    try testDecoding(CustomRankingCriterion.asc("attr").rawValue, expected: "asc(attr)")
    try testDecoding(CustomRankingCriterion.desc("attr").rawValue, expected: "desc(attr)")
  }

  func testEncoding() throws {
    try testEncoding("asc(attr)", expected: CustomRankingCriterion.asc("attr").rawValue)
    try testEncoding("desc(attr)", expected: CustomRankingCriterion.desc("attr").rawValue)
  }

}
