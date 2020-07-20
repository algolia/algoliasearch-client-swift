//
//  SearchableAttribute.swift
//  
//
//  Created by Vladislav Fitc on 11.03.2020.
//

import Foundation

public enum SearchableAttribute: Codable, Equatable {

  case `default`(Attribute)
  case unordered(Attribute)

}

extension SearchableAttribute: ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    self = .init(rawValue: value)
  }

}

extension SearchableAttribute: RawRepresentable {

  private enum Prefix: String {
    case unordered
  }

  private static let samePrioritySeparator = ","

  public var rawValue: String {
    switch self {
    case .default(let attribute):
      return attribute.rawValue
    case .unordered(let attribute):
      return PrefixedString(prefix: Prefix.unordered.rawValue, value: attribute.rawValue).description
    }
  }

  public init(rawValue: String) {
    if let prefixedString = PrefixedString(rawValue: rawValue), prefixedString.prefix == Prefix.unordered.rawValue {
      let attribute = Attribute(rawValue: prefixedString.value)
      self = .unordered(attribute)
    } else {
      self = .default(.init(rawValue: rawValue))
    }
  }

}
