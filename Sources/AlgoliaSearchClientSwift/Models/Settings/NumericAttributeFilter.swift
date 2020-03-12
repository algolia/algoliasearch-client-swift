//
//  NumericAttributeFilter.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation

enum NumericAttributeFilter: Equatable, Codable {
  
  case `default`(Attribute)
  case equalOnly(Attribute)
    
}

extension NumericAttributeFilter: RawRepresentable {
  
  private enum Prefix: String {
    case equalOnly
  }
  
  var rawValue: String {
    switch self {
    case .default(let attribute):
      return attribute.rawValue
    case .equalOnly(let attribute):
      return PrefixedString(prefix: Prefix.equalOnly.rawValue, value: attribute.rawValue).description
    }

  }
  
  init(rawValue: String) {
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
