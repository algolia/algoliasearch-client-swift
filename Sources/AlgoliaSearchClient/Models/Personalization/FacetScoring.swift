//
//  FacetScoring.swift
//  
//
//  Created by Vladislav Fitc on 27/05/2020.
//

import Foundation

/// Configure the importance of facets.
public struct FacetScoring: Codable {

  /// Attribute name.
  public let facetName: Attribute

  /// Score for the facet.
  public let score: Int?

}
