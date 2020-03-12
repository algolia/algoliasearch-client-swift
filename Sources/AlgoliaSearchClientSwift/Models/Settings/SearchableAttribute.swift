//
//  SearchableAttribute.swift
//  
//
//  Created by Vladislav Fitc on 11.03.2020.
//

import Foundation

enum SearchableAttribute: Codable, Equatable {
  
  case `default`([Attribute])
  case unordered(Attribute)
    
}

extension SearchableAttribute: RawRepresentable {
  
  private enum Prefix: String {
    case unordered
  }
  
  var rawValue: String {
    switch self {
    case .default(let attributes):
      return attributes.map { $0.rawValue }.joined(separator: ",")
    case .unordered(let attribute):
      return PrefixedString(prefix: Prefix.unordered.rawValue, value: attribute.rawValue).description
    }
  }
  
  init(rawValue: String) {
    if let prefixedString = PrefixedString(rawValue: rawValue), prefixedString.prefix == Prefix.unordered.rawValue {
      let attribute = Attribute(rawValue: prefixedString.value)
      self = .unordered(attribute)
    } else {
      let attributes = rawValue.split(separator: ",").map(String.init).map(Attribute.init)
      self = .`default`(attributes)
    }
  }
  
}
