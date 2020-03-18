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
