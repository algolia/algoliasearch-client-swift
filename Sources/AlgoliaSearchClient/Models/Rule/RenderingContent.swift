//
//  RenderingContent.swift
//  
//
//  Created by Vladislav Fitc on 11/03/2021.
//

import Foundation

/**
  * Content defining how the search interface should be rendered.
  * This is set via the settings for a default value and can be overridden via rules
  */
public struct RenderingContent: Codable {

  /// Defining how facets should be ordered
  public let facetOrdering: FacetOrdering?

}
