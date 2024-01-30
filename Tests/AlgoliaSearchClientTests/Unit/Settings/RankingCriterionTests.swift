//
//  RankingCriterionTests.swift
//
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation
import XCTest

@testable import AlgoliaSearchClient

class RankingCriterionTests: XCTestCase {
  func testCoding() throws {
    try AssertEncodeDecode(RankingCriterion.asc("attr"), "asc(attr)")
    try AssertEncodeDecode(RankingCriterion.desc("attr"), "desc(attr)")
    try AssertEncodeDecode(RankingCriterion.typo, "typo")
    try AssertEncodeDecode(RankingCriterion.geo, "geo")
    try AssertEncodeDecode(RankingCriterion.words, "words")
    try AssertEncodeDecode(RankingCriterion.filters, "filters")
    try AssertEncodeDecode(RankingCriterion.proximity, "proximity")
    try AssertEncodeDecode(RankingCriterion.attribute, "attribute")
    try AssertEncodeDecode(RankingCriterion.exact, "exact")
    try AssertEncodeDecode(RankingCriterion.custom, "custom")
  }
}
