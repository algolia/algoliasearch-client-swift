//
//  SynonymSearchResponse.swift
//  
//
//  Created by Vladislav Fitc on 11/05/2020.
//

import Foundation

public struct SynonymSearchResponse: Codable {

  /// A list of Hit.
  public let hits: [Hit]

  /// Number of hits.
  public let nbHits: Int

}
