//
//  Scope.swift
//  
//
//  Created by Vladislav Fitc on 01/04/2020.
//

import Foundation

/// Possible Scope to copy for a copyIndex operation.
public struct Scope: OptionSet {

  public let rawValue: Int

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  /// Scope for objects & settings & synonyms & rules
  public static let all: Self = []

  /// Scope for settings
  public static let settings = Self(rawValue: 1 << 0)

  /// Scope for synonyms
  public static let synonyms = Self(rawValue: 1 << 1)

  /// Scope for rules
  public static let rules = Self(rawValue: 1 << 2)

}

extension Scope {

  var components: [ScopeComponent]? {
    guard !isEmpty else {
      return nil
    }
    var output: [ScopeComponent] = []
    if contains(.settings) {
      output.append(.settings)
    }
    if contains(.synonyms) {
      output.append(.synonyms)
    }
    if contains(.rules) {
      output.append(.rules)
    }
    return output
  }

}

public struct ScopeComponent: StringOption & ProvidingCustomOption {

  public let rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }

  public static var settings: Self { .init(rawValue: #function) }

  public static var synonyms: Self { .init(rawValue: #function) }

  public static var rules: Self { .init(rawValue: #function) }

}
