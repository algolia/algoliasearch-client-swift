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

  func testCoding() throws {
    try AssertEncodeDecode(CustomRankingCriterion.asc("attr"), "asc(attr)")
    try AssertEncodeDecode(CustomRankingCriterion.desc("attr"), "desc(attr)")
  }

}
