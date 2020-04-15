//
//  AdvancedSyntaxFeatures.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation

public struct AdvancedSyntaxFeatures: StringOption, ProvidingCustomOption {
  
  public let rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }
  
  public static var exactPhrase: Self { .init(rawValue: #function) }
  public static var excludeWords: Self { .init(rawValue: #function) }
  
}
