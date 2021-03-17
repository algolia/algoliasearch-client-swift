//
//  FacetOrderContainer.swift
//  
//
//  Created by Vladislav Fitc on 17/03/2021.
//

import Foundation

public struct FacetOrderContainer: Codable {
      
  public let facetOrder: [AttributedFacets]
  
  public init(facetOrder: [AttributedFacets] = []) {
    self.facetOrder = facetOrder
  }
  
}
