//
//  AlternativesAsExactTests.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class AlternativesAsExactTests: XCTestCase {
  
  func testEncoding() {
    testEncoding(AlternativesAsExact.ignorePlurals, expected: "ignorePlurals")
    testEncoding(AlternativesAsExact.singleWordSynonym, expected: "singleWordSynonym")
    testEncoding(AlternativesAsExact.multiWordsSynonym, expected: "multiWordsSynonym")
    testEncoding(AlternativesAsExact.other("custom"), expected: "custom")
  }
  
  func testDecoding() {
    testDecoding("ignorePlurals", expected: AlternativesAsExact.ignorePlurals)
    testDecoding("singleWordSynonym", expected: AlternativesAsExact.singleWordSynonym)
    testDecoding("multiWordsSynonym", expected: AlternativesAsExact.multiWordsSynonym)
    testDecoding("custom", expected: AlternativesAsExact.other("custom"))
  }
  
}
