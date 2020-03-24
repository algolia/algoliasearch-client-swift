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

  func testEncoding() throws {
    try testEncoding(AlternativesAsExact.ignorePlurals, expected: "ignorePlurals")
    try testEncoding(AlternativesAsExact.singleWordSynonym, expected: "singleWordSynonym")
    try testEncoding(AlternativesAsExact.multiWordsSynonym, expected: "multiWordsSynonym")
    try testEncoding(AlternativesAsExact.other("custom"), expected: "custom")
  }

  func testDecoding() throws {
    try testDecoding("ignorePlurals", expected: AlternativesAsExact.ignorePlurals)
    try testDecoding("singleWordSynonym", expected: AlternativesAsExact.singleWordSynonym)
    try testDecoding("multiWordsSynonym", expected: AlternativesAsExact.multiWordsSynonym)
    try testDecoding("custom", expected: AlternativesAsExact.other("custom"))
  }

}
