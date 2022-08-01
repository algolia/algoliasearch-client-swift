//
//  PrefixeStringTests.swift
//  
//
//  Created by Vladislav Fitc on 18/07/2022.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class PrefixedStringTests: XCTestCase {
  
  func testPrefixedString() {
    let prefixedString = PrefixedString(rawValue: "prefix(value)")
    XCTAssertEqual(prefixedString?.prefix, "prefix")
    XCTAssertEqual(prefixedString?.value, "value")
  }
  
  func testPrefixedStringFailure() {
    let prefixedString = PrefixedString(rawValue: "prefix(value")
    XCTAssertNil(prefixedString)
  }
  
  func testPrefixedStringDecoding() throws {
    let data = try JSONEncoder().encode(JSON.string("prefix(value)"))
    let prefixedString = try JSONDecoder().decode(PrefixedString.self, from: data)
    XCTAssertEqual(prefixedString.prefix, "prefix")
    XCTAssertEqual(prefixedString.value, "value")
  }
  
  func testPrefixedStringDecodingFailure() throws {
    let data = try JSONEncoder().encode(JSON.string("prefix(value"))
    XCTAssertThrowsError(try JSONDecoder().decode(PrefixedString.self, from: data), "decoding of prefixed in wrong format might throw an error") { error in
      if case(.dataCorrupted(let context)) = error as? DecodingError {
        print(context.debugDescription)
      } else {
        XCTFail("unexpected error throws")
      }
    }
  }
  
}
