//
//  File.swift
//  
//
//  Created by Vladislav Fitc on 25/03/2020.
//

import Foundation

struct Cast<S> {
  
  let value: S
  
  init(_ value: S) {
    self.value = value
  }
  
  func callAsFunction<T>() throws -> T {
    if let output = value as? T {
      return output
    } else {
      throw TypecastError(sourceType: S.self, targetType: T.self)
    }
  }
  
}

struct TypecastError: Error {
  let localizedDescription: String
  init<S, T>(sourceType: S.Type, targetType: T.Type) {
    localizedDescription = "Impossible to cast \(sourceType.self) to \(targetType.self)"
  }
}
