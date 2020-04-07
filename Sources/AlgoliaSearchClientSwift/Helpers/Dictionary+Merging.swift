//
//  Dictionary+Merging.swift
//  
//
//  Created by Vladislav Fitc on 07/04/2020.
//

import Foundation

enum DictionaryMergingStrategy {
  case keepInitial
  case replaceWithNew
  
  func apply<Value>(firstValue: Value, secondValue: Value) -> Value {
    switch self {
    case .keepInitial:
      return firstValue
    case .replaceWithNew:
      return secondValue
    }
  }
  
}

extension Dictionary {
  func merging(_ other: [Key: Value], strategy: DictionaryMergingStrategy = .replaceWithNew) -> [Key: Value] {
    return merging(other, uniquingKeysWith: strategy.apply)
  }
}
