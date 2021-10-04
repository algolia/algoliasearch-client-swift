//
//  MultiSearchResponse.swift
//  
//
//  Created by Vladislav Fitc on 21/07/2021.
//

import Foundation

/// Wraps the list of multi search results (either FacetSearchResponse or SearchResponse)
public struct MultiSearchResponse: Codable {

  /// List of result in the order they were submitted, one element for each IndexedQuery.
  public var results: [Response]

  /// - parameter results: List of result in the order they were submitted, one element for each IndexedQuery.
  public init(results: [Response]) {
    self.results = results
  }

}

public extension MultiSearchResponse {

  /// Container for either FacetSearchResponse or SearchResponse
  enum Response: Codable {

    case facets(FacetSearchResponse)
    case hits(SearchResponse)

    public var facetsResponse: FacetSearchResponse? {
      if case .facets(let response) = self {
        return response
      } else {
        return .none
      }
    }

    public var hitsResponse: SearchResponse? {
      if case .hits(let response) = self {
        return response
      } else {
        return .none
      }
    }

    public init(from decoder: Decoder) throws {
      do {
        let searchResponse = try SearchResponse(from: decoder)
        self = .hits(searchResponse)
      } catch let searchResponseError {
        do {
          let facetSearchResponse = try FacetSearchResponse(from: decoder)
          self = .facets(facetSearchResponse)
        } catch let facetSearchResponseError {
          throw DecodingError(searchResponseDecodingError: searchResponseError,
                              facetSearchResponseDecodingError: facetSearchResponseError)
        }
      }
    }

    public func encode(to encoder: Encoder) throws {
      switch self {
      case .facets(let response):
        try response.encode(to: encoder)
      case .hits(let response):
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
