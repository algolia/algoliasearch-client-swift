//
//  DictionaryName.swift
//  
//
//  Created by Vladislav Fitc on 20/01/2021.
//

import Foundation

public struct DictionaryName: StringOption {

  public static var stopwords: Self { .init(rawValue: #function) }
  public static var plurals: Self { .init(rawValue: #function) }
  public static var compounds: Self { .init(rawValue: #function) }

  public let rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }

}
