//
//  XCTest+Codable.swift
//  
//
//  Created by Vladislav Fitc on 11.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

protocol AnyEquatable: Any where Self: Equatable {}


extension XCTestCase {
  
  func testEncoding<T: Encodable, M: Equatable>(_ value: T, expected: M) {
    let encoder = JSONEncoder()
    do {
      let data = try encoder.encode(value)
      let jsonObject = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
      guard let encodedValue = jsonObject as? M else {
        XCTFail("Impossible to cast json object to \(M.self)")
        return
      }
      XCTAssertEqual(encodedValue, expected)
    } catch let error {
      XCTFail("\(error)")
    }
  }
  
  func testEncoding<T: Encodable>(_ value: T, expectedJSONString: String) {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    do {
      let data = try encoder.encode(value)
      let jsonString = String(data: data, encoding: .utf8)
      XCTAssertEqual(jsonString, expectedJSONString)
    } catch let error {
      XCTFail("\(error)")
    }
  }

  func testDecoding<T: Decodable & Equatable>(_ input: Any, expected: T) {
    let rawData = try! JSONSerialization.data(withJSONObject: input, options: .fragmentsAllowed)
    let decoder = JSONDecoder()
    let decodedValue = try! decoder.decode(T.self, from: rawData)
    XCTAssertEqual(decodedValue, expected)
  }
  
  func testDecoding<T: Decodable & Equatable>(jsonString: String, expected: T) {
    let rawData = try! JSONSerialization.data(withJSONObject: jsonString, options: .fragmentsAllowed)
    let decoder = JSONDecoder()
    let decodedValue = try! decoder.decode(T.self, from: rawData)
    XCTAssertEqual(decodedValue, expected)
  }
  
  func testDecoding<T: Decodable>(fromFileWithName filename: String) throws -> T {
      let data = try Data(filename: filename)
      let decoder = JSONDecoder()
      return try decoder.decode(T.self, from: data)
  }
  
}

