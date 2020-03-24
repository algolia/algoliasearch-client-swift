//
//  AdvancedSyntaxFeaturesTests.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class AdvancedSyntaxFeaturesTests: XCTestCase {

  func testDecoding() throws {
    try testDecoding(AdvancedSyntaxFeatures.exactPhrase.rawValue, expected: "exactPhrase")
    try testDecoding(AdvancedSyntaxFeatures.excludeWords.rawValue, expected: "excludeWords")
    try testDecoding(AdvancedSyntaxFeatures.other("customFeature").rawValue, expected: "customFeature")
  }

  func testEncoding() throws {
    try testEncoding("exactPhrase", expected: AdvancedSyntaxFeatures.exactPhrase.rawValue)
    try testEncoding("excludeWords", expected: AdvancedSyntaxFeatures.excludeWords.rawValue)
    try testEncoding("customFeature", expected: AdvancedSyntaxFeatures.other("customFeature").rawValue)
  }

}
