//
//  File.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation

public protocol StringWrapper: RawRepresentable, Codable, CustomStringConvertible, ExpressibleByStringLiteral where RawValue == String {
  init(rawValue: String)
}

extension StringWrapper {
  
  public init(stringLiteral value: String) {
    self.init(rawValue: value)
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self.init(rawValue: rawValue)
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }
  
  public var description: String {
    return rawValue
  }
  
}
