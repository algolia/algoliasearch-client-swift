//
//  AttributeForFaceting.swift
//  
//
//  Created by Vladislav Fitc on 11.03.2020.
//

import Foundation

enum AttributeForFaceting: Equatable, Codable {
  
  case `default`(Attribute)
  case filterOnly(Attribute)
  case searchable(Attribute)
    
}

extension AttributeForFaceting: RawRepresentable {
  
  private enum Prefix: String {
    case filterOnly
    case searchable
  }
  
  var rawValue: String {
    switch self {
    case .default(let attribute):
      return attribute.rawValue
    case .filterOnly(let attribute):
      return PrefixedString(prefix: Prefix.filterOnly.rawValue, value: attribute.rawValue).description
    case .searchable(let attribute):
      return PrefixedString(prefix: Prefix.searchable.rawValue, value: attribute.rawValue).description
    }

  }
  
  init(rawValue: String) {
    if
      let prefixedString = PrefixedString(rawValue: rawValue),
      let prefix = Prefix(rawValue: prefixedString.prefix) {
      switch prefix {
      case .filterOnly:
        self = .filterOnly(.init(rawValue: prefixedString.value))
      case .searchable:
        self = .searchable(.init(rawValue: prefixedString.value))
      }
    } else {
      self = .default(.init(rawValue: rawValue))
    }
  }
  
}
