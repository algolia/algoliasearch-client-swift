//
//  PrefixedString.swift
//  
//
//  Created by Vladislav Fitc on 11.03.2020.
//

import Foundation

struct PrefixedString: CustomStringConvertible, Codable {

  let prefix: String
  let value: String

  init(prefix: String, value: String) {
    self.prefix = prefix
    self.value = value
  }

  init?(rawValue: String) {
    guard let leftIndex = rawValue.firstIndex(of: "(") else { return nil }
    guard let rightIndex = rawValue.lastIndex(of: ")") else { return nil }
    self.prefix = String(rawValue.prefix(upTo: leftIndex))
    let valueStartIndex = rawValue.index(leftIndex, offsetBy: 1)
    self.value = String(rawValue[valueStartIndex..<rightIndex])
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    if let prefixedString = PrefixedString(rawValue: rawValue) {
      self = prefixedString
    } else {
      throw Error.wrongFormat
    }
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(description)
  }

  var description: String {
    return "\(prefix)(\(value))"
  }

  enum Error: Swift.Error {
    case wrongFormat
  }

}

extension PrefixedString {

  static func matching(_ rawValue: String, prefix: String) -> String? {
    guard let prefixedString = PrefixedString(rawValue: rawValue), prefixedString.prefix == prefix else {
      return nil
    }
    return prefixedString.value
  }

}
