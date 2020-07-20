//
//  StringNumberContainer.swift
//  
//
//  Created by Vladislav Fitc on 06/04/2020.
//

import Foundation

/**
  Helper structure ensuring the decoding of a number value from a "volatile" JSON
  occasionally providing number values in the form of String
*/
struct StringNumberContainer: RawRepresentable, Codable {

  let rawValue: Double

  var intValue: Int {
    return Int(rawValue)
  }

  var floatValue: Float {
    return Float(rawValue)
  }

  init(rawValue: Double) {
    self.rawValue = rawValue
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let doubleValue = try? container.decode(Double.self) {
      self.rawValue = doubleValue
      return
    }
    if let doubleFromString = Double(try container.decode(String.self)) {
      self.rawValue = doubleFromString
      return
    }
    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Value cannot be decoded neither to Double nor to String representing Double value")
  }

}
