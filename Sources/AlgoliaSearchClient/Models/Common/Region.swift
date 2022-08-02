//
//  Region.swift
//  
//
//  Created by Vladislav Fitc on 23/04/2020.
//
// swiftlint:disable identifier_name

import Foundation

public struct Region: StringOption, ProvidingCustomOption {

  public static var us: Self { .init(rawValue: #function) }

  /// European (Germany) region for Insights and Analytics APIs
  public static var de: Self { .init(rawValue: #function) }

  /// European region for Personalization API
  public static var eu: Self { .init(rawValue: #function) }

  public let rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }

}
