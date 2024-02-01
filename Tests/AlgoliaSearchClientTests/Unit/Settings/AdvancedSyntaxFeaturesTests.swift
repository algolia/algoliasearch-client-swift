//
//  AdvancedSyntaxFeaturesTests.swift
//
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation
import XCTest

@testable import AlgoliaSearchClient

class AdvancedSyntaxFeaturesTests: XCTestCase {
  func testCoding() throws {
    try AssertEncodeDecode(AdvancedSyntaxFeatures.exactPhrase, "exactPhrase")
    try AssertEncodeDecode(AdvancedSyntaxFeatures.excludeWords, "excludeWords")
    try AssertEncodeDecode(AdvancedSyntaxFeatures.custom("customFeature"), "customFeature")
  }
}
