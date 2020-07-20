//
//  NumericAttributeFilter.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation

public enum NumericAttributeFilter: Equatable, Codable {

  case `default`(Attribute)
  case equalOnly(Attribute)

}

extension NumericAttributeFilter: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self.init(rawValue: value)
  }
}

extension NumericAttributeFilter: RawRepresentable {

  private enum Prefix: String {
    case equalOnly
  }

  public var rawValue: String {
    switch self {
    case .default(let attribute):
      return attribute.rawValue
    case .equalOnly(let attribute):
      return PrefixedString(prefix: Prefix.equalOnly.rawValue, value: attribute.rawValue).description
    }

  }

  public init(rawValue: String) {
    if
      let prefixedString = PrefixedString(rawValue: rawValue),
      let prefix = Prefix(rawValue: prefixedString.prefix) {
      switch prefix {
      case .equalOnly:
        self = .equalOnly(.init(rawValue: prefixedString.value))
      }
    } else {
      self = .default(.init(rawValue: rawValue))
    }
  }

}
