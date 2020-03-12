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
  
  func testDecoding() {
    testDecoding(AdvancedSyntaxFeatures.exactPhrase.rawValue, expected: "exactPhrase")
    testDecoding(AdvancedSyntaxFeatures.excludeWords.rawValue, expected: "excludeWords")
    testDecoding(AdvancedSyntaxFeatures.other("customFeature").rawValue, expected: "customFeature")
  }
  
  func testEncoding() {
    testEncoding("exactPhrase", expected: AdvancedSyntaxFeatures.exactPhrase.rawValue)
    testEncoding("excludeWords", expected: AdvancedSyntaxFeatures.excludeWords.rawValue)
    testEncoding("customFeature", expected: AdvancedSyntaxFeatures.other("customFeature").rawValue)
  }
  
}
