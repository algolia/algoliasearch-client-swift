//
//  FacetsOrder.swift
//  
//
//  Created by Vladislav Fitc on 15/06/2021.
//

import Foundation

/// Facets ordering rule container
public struct FacetsOrder {

  /// Pinned order of facet lists.
  public let order: [Attribute]

  /// - parameter order: pinned order of facet lists.
  public init(order: [Attribute] = []) {
    self.order = order
  }

}

extension FacetsOrder: Codable {

  enum CodingKeys: String, CodingKey {
    case order
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.order = try container.decodeIfPresent(forKey: .order) ?? []
  }

}
