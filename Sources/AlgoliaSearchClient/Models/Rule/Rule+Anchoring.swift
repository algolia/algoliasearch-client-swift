//
//  Rule+Anchoring.swift
//  
//
//  Created by Vladislav Fitc on 05/05/2020.
//

import Foundation

extension Rule {

  public struct Anchoring: StringOption, ProvidingCustomOption {

    public let rawValue: String

    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    /// The Pattern matches the query.
    public static var `is`: Self { .init(rawValue: #function) }

    /// The Pattern matches the beginning of the query.
    public static var startsWith: Self { .init(rawValue: #function) }

    /// The Pattern matches the beginning of the query.
    public static var endsWith: Self { .init(rawValue: #function) }

    /// The Pattern is contained by the query.
    public static var contains: Self { .init(rawValue: #function) }

  }

}
