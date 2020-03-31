//
//  RemoveStopWordsTests.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class RemoveStopWordsTests: XCTestCase {

  func testCoding() throws {
    try AssertEncodeDecode(RemoveStopWords.true, true)
    try AssertEncodeDecode(RemoveStopWords.false, false)
    try AssertEncodeDecode(RemoveStopWords.queryLanguages([.english, .polish, .french]), ["en", "pl", "fr"])
  }

}
