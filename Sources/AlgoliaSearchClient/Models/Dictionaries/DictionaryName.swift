//
//  DictionaryName.swift
//  
//
//  Created by Vladislav Fitc on 20/01/2021.
//

import Foundation

public enum DictionaryName: String {
  case stopwords
  case plurals
  case compounds
}

extension DictionaryName {
  
  static func forEntry<E: DictionaryEntry>(_ entry: E.Type) -> DictionaryName {
    switch entry {
    case is StopWord.Type:
      return stopwords
    case is Plural.Type:
      return plurals
    case is Compound.Type:
      return compounds
    default:
      fatalError("No dictionary defined for entry: \(entry)")
    }
  }
  
}
