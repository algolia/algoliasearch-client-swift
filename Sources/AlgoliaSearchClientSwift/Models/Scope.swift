//
//  Scope.swift
//  
//
//  Created by Vladislav Fitc on 01/04/2020.
//

import Foundation

/// Possible Scope to copy for a copyIndex operation.
public struct Scope: StringOption & ProvidingCustomOption {
  
  public let rawValue: String
  
  public init(rawValue: RawValue) {
    self.rawValue = rawValue
  }
  
  /// Scope for Settings
  public static var settings: Self { .init(rawValue: #function) }
  
  /// Scope for Synonym
  public static var synonyms: Self { .init(rawValue: #function) }
  
  /// Scope for Rule
  public static var rules: Self { .init(rawValue: #function) }
    
}
