//
//  SearchResponse.swift
//  
//
//  Created by Vladislav Fitc on 17.02.2020.
//

import Foundation

public struct SearchResponse: Codable {
  
  
  /// Search hits
  public let hits: [Hit<JSON>]
  
  /// Total number of hits.
  public let nbHits: Int
    
}

public extension SearchResponse {
  
  func extractHits<T: Decodable>() throws -> [T] {
    let hitsData = try JSONEncoder().encode(hits.map { $0.object })
    return try JSONDecoder().decode([T].self, from: hitsData)
  }
  
}
