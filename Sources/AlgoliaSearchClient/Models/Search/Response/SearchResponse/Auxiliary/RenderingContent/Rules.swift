//
//  Rules.swift
//  
//
//  Created by Vladislav Fitc on 17/03/2021.
//

import Foundation

public extension SearchResponse {
  
  struct Rules: Codable {
    
    public let consequence: Consequence?
    
    //TODO: temporary decoding for prototype
    public init(from decoder: Decoder) throws {
      let userData = try [JSON](from: decoder)
      let redirect = (userData[0]["link"]?.object() as? String).flatMap(URL.init(string:)).flatMap(Redirect.init(url:))
      let facetOrder = userData.first
        .flatMap { try? JSONEncoder().encode($0) }
        .flatMap { try? JSONDecoder().decode(FacetOrderContainer.self, from: $0) }
      self.consequence = .init(
        renderingContent: .init(
          redirect: redirect,
          facetMerchandising: facetOrder,
          userData: userData
        ))
    }
  }
  
}

public extension SearchResponse.Rules {
  
  struct Consequence: Codable {
    public let renderingContent: RenderingContent?
  }
  
}
