//
//  FacetOrderContainer.swift
//  
//
//  Created by Vladislav Fitc on 17/03/2021.
//

import Foundation

public struct FacetOrderContainer: Codable {
      
  public let facetOrdering: FacetOrdering
  
  public init(facetOrdering: FacetOrdering = .init()) {
    self.facetOrdering = facetOrdering
  }
  
}

public struct FacetOrdering {
  
  public let facets: FacetsOrder
  
  public let values: [Attribute: FacetValuesOrder]
  
  public init(facets: FacetsOrder = .init(),
              values: [Attribute: FacetValuesOrder] = [:]) {
    self.facets = facets
    self.values = values
  }
  
}

extension FacetOrdering: Codable {
  
  enum CodingKeys: String, CodingKey {
    case facets
    case values
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.facets = try container.decode(forKey: .facets)
    let rawValues = try container.decode([String: FacetValuesOrder].self, forKey: .values)
    self.values = rawValues.mapKeys(Attribute.init)
  }
  
}

public struct FacetsOrder: Codable {
  
  public let order: [Attribute]
  
  public init(order: [Attribute] = []) {
    self.order = order
  }
  
}

public struct FacetValuesOrder: Codable {
  
  public let order: [String]?
  public let sortRemainingBy: SortRule?
  
  public enum SortRule: String, Codable {
    case alpha
    case count
    case hidden
  }
  
  public init(order: [String] = [],
              sortRemainingBy: SortRule? = nil) {
    self.order = order
    self.sortRemainingBy = sortRemainingBy
  }
  
}
