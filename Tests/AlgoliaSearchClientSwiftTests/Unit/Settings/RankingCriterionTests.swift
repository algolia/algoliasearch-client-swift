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

  func testDecoding() throws {
    try testDecoding("asc(attr)", expected: RankingCriterion.asc("attr"))
    try testDecoding("desc(attr)", expected: RankingCriterion.desc("attr"))
    try testDecoding("typo", expected: RankingCriterion.typo)
    try testDecoding("geo", expected: RankingCriterion.geo)
    try testDecoding("words", expected: RankingCriterion.words)
    try testDecoding("filters", expected: RankingCriterion.filters)
    try testDecoding("proximity", expected: RankingCriterion.proximity)
    try testDecoding("attribute", expected: RankingCriterion.attribute)
    try testDecoding("exact", expected: RankingCriterion.exact)
    try testDecoding("custom", expected: RankingCriterion.custom)
  }

  func testEncoding() throws {
    try testEncoding(RankingCriterion.asc("attr"), expected: "asc(attr)")
    try testEncoding(RankingCriterion.desc("attr"), expected: "desc(attr)")
    try testEncoding(RankingCriterion.typo, expected: "typo")
    try testEncoding(RankingCriterion.geo, expected: "geo")
    try testEncoding(RankingCriterion.words, expected: "words")
    try testEncoding(RankingCriterion.filters, expected: "filters")
    try testEncoding(RankingCriterion.proximity, expected: "proximity")
    try testEncoding(RankingCriterion.attribute, expected: "attribute")
    try testEncoding(RankingCriterion.exact, expected: "exact")
    try testEncoding(RankingCriterion.custom, expected: "custom")
  }

}
