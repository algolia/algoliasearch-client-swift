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

public struct FacetOrdering: Codable {
  
  public let facets: OrderingRule
  public let facetValues: [String: OrderingRule]
  
  public init(facets: OrderingRule = .init(),
              facetValues: [String: OrderingRule] = [:]) {
    self.facets = facets
    self.facetValues = facetValues
  }
  
}


public struct OrderingRule: Codable {
  
  public let order: [String]?
  public let hide: [String]?
  public let sortBy: SortRule?
  
  public enum SortRule: String, Codable {
    case alpha
    case count
  }
  
  public init(order: [String] = ["*"],
              hide: [String]? = nil,
              sortBy: SortRule? = nil) {
    self.order = order
    self.hide = hide
    self.sortBy = sortBy
  }
  
}
