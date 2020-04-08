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

  func testCoding() throws {
    try AssertEncodeDecode(AlternativesAsExact.ignorePlurals, "ignorePlurals")
    try AssertEncodeDecode(AlternativesAsExact.singleWordSynonym, "singleWordSynonym")
    try AssertEncodeDecode(AlternativesAsExact.multiWordsSynonym, "multiWordsSynonym")
    try AssertEncodeDecode(AlternativesAsExact.custom("custom"), "custom")
  }

}
