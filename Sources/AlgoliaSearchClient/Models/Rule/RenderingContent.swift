//
//  RenderingContent.swift
//  
//
//  Created by Vladislav Fitc on 11/03/2021.
//

import Foundation

public struct RenderingContent: Codable {
  
  public let redirect: Redirect?
  public let facetMerchandising: FacetOrderContainer?
  public let userData: [JSON]?
  
}
