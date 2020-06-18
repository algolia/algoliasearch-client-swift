//
//  FacetsStorage.swift
//  
//
//  Created by Vladislav Fitc on 13/04/2020.
//

import Foundation

struct FacetsStorage: Codable {

  var storage: [Attribute: [Facet]]

  public init(storage: [Attribute: [Facet]]) {
    self.storage = storage
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawFacetsForAttribute = try container.decode([String: [String: Int]].self)
    let output = [Attribute: [Facet]](rawFacetsForAttribute)
    self.storage = output
  }

  func encode(to encoder: Encoder) throws {
    let rawFacets = [String: [String: Int]](storage)
    var container = encoder.singleValueContainer()
    try container.encode(rawFacets)
  }

}
