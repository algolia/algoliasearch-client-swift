//
//  AttributedFacets.swift
//  
//
//  Created by Vladislav Fitc on 17/03/2021.
//

import Foundation

public struct AttributedFacets: Codable {

  public let attribute: Attribute
  public let facets: [Facet]

  enum CodingKeys: String, CodingKey {
    case attribute
    case facets = "values"
  }

  public init(attribute: Attribute, facets: [Facet]) {
    self.attribute = attribute
    self.facets = facets
  }

}
