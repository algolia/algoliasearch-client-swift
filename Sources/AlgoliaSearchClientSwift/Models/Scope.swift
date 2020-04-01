//
//  Scope.swift
//  
//
//  Created by Vladislav Fitc on 01/04/2020.
//

import Foundation

/**
 Possible Scope to copy for a copyIndex operation.
*/
enum Scope: Codable {
  
  /**
   Scope for [com.algolia.search.model.settings.Settings]
  */
  case settings
  
  /**
   Scope for [com.algolia.search.model.synonym.Synonym]
  */
  case synonyms
  
  /**
   Scope for [com.algolia.search.model.rule.Rule]
  */
  case rules
  
  case other(String)
  
}

extension Scope: RawRepresentable {
  
  var rawValue: String {
    switch self {
    case .settings:
      return "settings"
    case .synonyms:
      return "synonyms"
    case .rules:
      return "rules"
    case .other(let value):
      return value
    }
  }
  
  init(rawValue: String) {
    switch rawValue {
    case Scope.settings.rawValue:
      self = .settings
    case Scope.synonyms.rawValue:
      self = .synonyms
    case Scope.rules.rawValue:
      self = .rules
    default:
      self = .other(rawValue)
    }
  }
  
}
