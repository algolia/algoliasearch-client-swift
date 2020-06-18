//
//  FacetStatsStorage.swift
//  
//
//  Created by Vladislav Fitc on 14/04/2020.
//

import Foundation

struct FacetStatsStorage: Codable {

  var storage: [Attribute: FacetStats]

  public init(storage: [Attribute: FacetStats]) {
    self.storage = storage
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawFacetsForAttribute = try container.decode([String: FacetStats].self)
    let keyValues = rawFacetsForAttribute.map { (Attribute(rawValue: $0.key), $0.value) }
    self.storage = .init(uniqueKeysWithValues: keyValues)
  }

  public func encode(to encoder: Encoder) throws {
    let keyValues = storage.map { ($0.key.rawValue, $0.value) }
    let rawFacets = [String: FacetStats].init(uniqueKeysWithValues: keyValues)
    var container = encoder.singleValueContainer()
    try container.encode(rawFacets)
  }

}
