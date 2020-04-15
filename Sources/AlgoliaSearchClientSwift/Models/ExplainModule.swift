//
//  ExplainModule.swift
//  
//
//  Created by Vladislav Fitc on 23/03/2020.
//

import Foundation

public struct ExplainModule: StringOption & ProvidingCustomOption {
  
  public let rawValue: String
  
  public init(rawValue: RawValue) {
    self.rawValue = rawValue
  }
  
  public static var matchAlternatives: Self { .init(rawValue: "match.alternatives") }
  
}
