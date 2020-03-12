//
//  RankingCriterionTests.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift


class RankingCriterionTests: XCTestCase {
  
  func testDecoding() {
    testDecoding("asc(attr)", expected: RankingCriterion.asc("attr"))
    testDecoding("desc(attr)", expected: RankingCriterion.desc("attr"))
    testDecoding("typo", expected: RankingCriterion.typo)
    testDecoding("geo", expected: RankingCriterion.geo)
    testDecoding("words", expected: RankingCriterion.words)
    testDecoding("filters", expected: RankingCriterion.filters)
    testDecoding("proximity", expected: RankingCriterion.proximity)
    testDecoding("attribute", expected: RankingCriterion.attribute)
    testDecoding("exact", expected: RankingCriterion.exact)
    testDecoding("custom", expected: RankingCriterion.custom)
  }
  
  func testEncoding() {
    testEncoding(RankingCriterion.asc("attr"), expected: "asc(attr)")
    testEncoding(RankingCriterion.desc("attr"), expected: "desc(attr)")
    testEncoding(RankingCriterion.typo, expected: "typo")
    testEncoding(RankingCriterion.geo, expected: "geo")
    testEncoding(RankingCriterion.words, expected: "words")
    testEncoding(RankingCriterion.filters, expected: "filters")
    testEncoding(RankingCriterion.proximity, expected: "proximity")
    testEncoding(RankingCriterion.attribute, expected: "attribute")
    testEncoding(RankingCriterion.exact, expected: "exact")
    testEncoding(RankingCriterion.custom, expected: "custom")
  }

}
