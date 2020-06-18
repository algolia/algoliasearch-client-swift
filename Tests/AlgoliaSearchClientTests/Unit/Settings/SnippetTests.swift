//
//  SnippetTests.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class SnippetTests: XCTestCase {

  func testCoding() throws {
    try AssertEncodeDecode(Snippet(attribute: "attr"), "attr")
    try AssertEncodeDecode(Snippet(attribute: "attr", count: 20), "attr:20")

  }

}
