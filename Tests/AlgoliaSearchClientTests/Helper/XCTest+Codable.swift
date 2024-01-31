//
//  XCTest+Codable.swift
//  
//
//  Created by Vladislav Fitc on 11.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

func AssertEncodeDecode<T: Codable>(_ value: T, _ rawValue: JSON, file: StaticString = #file, line: UInt = #line) throws {
  try AssertEncode(value, expected: rawValue, file: file, line: line)
  try AssertDecode(rawValue, expected: value, file: file, line: line)
}

func AssertMatch(_ data: Data, _ expected: JSON, file: StaticString = #file, line: UInt = #line) {
  let jsonDecoder = JSONDecoder()
  jsonDecoder.dateDecodingStrategy = .swiftAPIClient
  do {
    let decoded = try jsonDecoder.decode(JSON.self, from: data)
    XCTAssertEqual(decoded, expected)
  } catch let error {
    XCTFail("Failed decoding: \(error)")
  }
}

func AssertDecode<T: Codable & Equatable>(_ input: JSON, expected: T, file: StaticString = #file, line: UInt = #line) throws {

  let encoder = JSONEncoder()
  encoder.dateEncodingStrategy = .swiftAPIClient
  let data = try encoder.encode(input)

  let jsonDecoder = JSONDecoder()
  jsonDecoder.dateDecodingStrategy = .swiftAPIClient
  let decoded = try jsonDecoder.decode(T.self, from: data)

  XCTAssertEqual(expected, decoded, file: (file), line: line)
}

func AssertDecode<T: Codable>(_ input: JSON, expected: T, file: StaticString = #file, line: UInt = #line) throws {

  let encoder = JSONEncoder()
  encoder.dateEncodingStrategy = .swiftAPIClient
  let data = try encoder.encode(input)

  let jsonDecoder = JSONDecoder()
  jsonDecoder.dateDecodingStrategy = .swiftAPIClient
  let decoded = try jsonDecoder.decode(T.self, from: data)
  
  let decodedJSON = try JSON(decoded)
  let expectedJSON = try JSON(expected)

  XCTAssertEqual(expectedJSON, decodedJSON, file: (file), line: line)
}

@discardableResult func AssertDecode<T: Decodable>(jsonFilename filename: String, expected: T.Type, file: StaticString = #file, line: UInt = #line) throws -> T {
  let data = try Data(filename: filename)
  return try JSONDecoder().decode(T.self, from: data)
}

func AssertEncode<T: Encodable>(_ value: T, expected: JSON, file: StaticString = #file, line: UInt = #line) throws {

  let encoder = JSONEncoder()
  encoder.dateEncodingStrategy = .swiftAPIClient
  let valueData = try encoder.encode(value)

  let jsonDecoder = JSONDecoder()
  jsonDecoder.dateDecodingStrategy = .swiftAPIClient
  let jsonFromValue = try jsonDecoder.decode(JSON.self, from: valueData)

  XCTAssertEqual(jsonFromValue, expected, file: (file), line: line)
}

func AssertEquallyEncoded<A: Encodable, B: Encodable>(_ l: A, _ r: B, file: StaticString = #file, line: UInt = #line) throws {
  let encoder = JSONEncoder()
  encoder.dateEncodingStrategy = .swiftAPIClient
  let lData = try encoder.encode(l)
  let rData = try encoder.encode(r)
  let decoder = JSONDecoder()
  try XCTAssertEqual(decoder.decode(JSON.self, from: lData), decoder.decode(JSON.self, from: rData))
}

func AssertJSONEqual(_ data1: Data?,
                     _ data2: Data?,
                     message: String = "JSON objects are not equal",
                     file: StaticString = #file,
                     line: UInt = #line) {
  guard let data1, let data2 else {
    XCTAssertEqual(data1,
                   data2,
                   file: file,
                   line: line)
    return
  }
  
  do {
    let json1 = try JSONSerialization.jsonObject(with: data1, options: [])
    let json2 = try JSONSerialization.jsonObject(with: data2, options: [])
    
    // Convert NSDictionary to [AnyHashable: Any]
    if let dict1 = json1 as? [AnyHashable: Any], let dict2 = json2 as? [AnyHashable: Any] {
      if NSDictionary(dictionary: dict1).isEqual(to: dict2) {
        // JSON objects are equal
      } else {
        XCTFail(message, file: file, line: line)
      }
    } else if let array1 = json1 as? [Any], let array2 = json2 as? [Any] {
      if NSArray(array: array1).isEqual(to: array2) {
        // JSON objects (arrays) are equal
      } else {
          XCTFail(message, file: file, line: line)
      }
    } else {
      XCTFail("JSON objects are not dictionaries", file: file, line: line)
    }
  } catch {
    XCTFail("JSON conversion failed: \(error)", file: file, line: line)
  }
}

