//
//  FilterVariant.swift
//  
//
//  Created by Vladislav Fitc on 07/07/2020.
//

import Foundation

public struct FilterVariant {
  public let storage: SingleOrList<String>
}

extension FilterVariant: ExpressibleByStringLiteral {
  
  public init(stringLiteral value: String) {
    self.storage = .single(value)
  }
  
}

extension FilterVariant {
  
  public static func or(_ values: String...) -> FilterVariant {
    return .init(storage: .list(values))
  }
  
}

extension FilterVariant: Codable {
  
  public init(from decoder: Decoder) throws {
    let storage = try SingleOrList<String>(from: decoder)
    self = .init(storage: storage)
  }
  
  public func encode(to encoder: Encoder) throws {
    try storage.encode(to: encoder)
  }
  
}
