//
//  PlacesResponse.swift
//  
//
//  Created by Vladislav Fitc on 14/04/2020.
//

import Foundation

public struct PlacesResponse<T: Codable>: Codable {

  public let hits: [T]
  public let nbHits: Int
  public let processingTimeMS: TimeInterval
  public let params: String
  public let query: String?
  public let parsedQuery: String?

}
