//
//  MultiIndexSearchResponse.swift
//  
//
//  Created by Vladislav Fitc on 21/07/2021.
//

import Foundation

public struct MultiIndexSearchResponse: Codable {
      
  public var results: [Response]
  
  public init(results: [Response]) {
    self.results = results
  }

}

public extension MultiIndexSearchResponse {
  
  /// Unit response container for either FacetSearchResponse, or SearchResponse
  enum Response: Codable {
          
    case facet(FacetSearchResponse)
    case search(SearchResponse)
    
    public init(from decoder: Decoder) throws {
      do {
        let searchResponse = try SearchResponse(from: decoder)
        self = .search(searchResponse)
      } catch let searchResponseError {
        do {
          let facetSearchResponse = try FacetSearchResponse(from: decoder)
          self = .facet(facetSearchResponse)
        } catch let facetSearchResponseError {
          throw DecodingError(searchResponseDecodingError: searchResponseError,
                              facetSearchResponseDecodingError: facetSearchResponseError)
        }
      }
    }
    
    public func encode(to encoder: Encoder) throws {
      switch self {
      case .facet(let response):
        try response.encode(to: encoder)
      case .search(let response):
        try response.encode(to: encoder)
      }
    }
    
    public struct DecodingError: Error {
      
      /// Error occured while search response decoding
      public let searchResponseDecodingError: Error
      
      /// Error occured while facets search response decoding
      public let facetSearchResponseDecodingError: Error
      
      init(searchResponseDecodingError: Error,
           facetSearchResponseDecodingError: Error) {
        self.searchResponseDecodingError = searchResponseDecodingError
        self.facetSearchResponseDecodingError = facetSearchResponseDecodingError
      }
      
    }
    
  }
    
}
