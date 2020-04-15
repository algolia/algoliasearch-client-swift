//
//  AlternativesAsExact.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation

public struct AlternativesAsExact: StringOption, ProvidingCustomOption {
  
  public let rawValue: String
  
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
  
  public static var ignorePlurals: Self { .init(rawValue: #function) }
  public static var singleWordSynonym: Self { .init(rawValue: #function) }
  public static var multiWordsSynonym: Self { .init(rawValue: #function) }
  
}
