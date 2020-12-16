//
//  SearchesResponse.swift
//  
//
//  Created by Vladislav Fitc on 04/04/2020.
//

import Foundation

public struct SearchesResponse: Codable {

  /// List of result in the order they were submitted, one element for each IndexQuery.
  public var results: [SearchResponse]

  public init(results: [SearchResponse]) {
    self.results = results
  }

}

extension SearchesResponse: Builder {}
