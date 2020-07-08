//
//  FilterVariant.swift
//  
//
//  Created by Vladislav Fitc on 07/07/2020.
//

import Foundation

public struct FilterVariant: Equatable {
  
  public let storage: SingleOrList<String>
  
  public init(and filter: String) {
    self.storage = .single(filter)
  }
  
  public init(or filters: [String]) {
    self.storage = .list(filters)
  }
  
  init(storage: SingleOrList<String>) {
    self.storage = storage
  }
  
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
