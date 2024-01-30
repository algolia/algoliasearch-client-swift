//
//  StringOption.swift
//
//
//  Created by Vladislav Fitc on 08/04/2020.
//

import Foundation

public protocol StringOption: Codable, Equatable, RawRepresentable where RawValue == String {}

extension StringOption {
  public init(rawValue: RawValue) {
    self.init(rawValue: rawValue)!
  }
}

public protocol ProvidingCustomOption {
  static func custom(_ value: String) -> Self
}

extension ProvidingCustomOption where Self: StringOption {
  public static func custom(_ value: String) -> Self { .init(rawValue: value) }
}

extension ExpressibleByStringInterpolation where Self: StringOption {
  init(stringLiteral value: String) {
    self = .init(rawValue: value)
  }
}
