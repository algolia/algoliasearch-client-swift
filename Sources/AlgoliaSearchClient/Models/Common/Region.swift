//
//  Region.swift
//  
//
//  Created by Vladislav Fitc on 23/04/2020.
//

import Foundation

public struct Region: StringOption, ProvidingCustomOption {

  public static var us: Self { .init(rawValue: #function) }
  public static var de: Self { .init(rawValue: #function) }

  public let rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }

}
