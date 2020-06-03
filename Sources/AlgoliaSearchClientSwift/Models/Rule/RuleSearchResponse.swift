//
//  RuleSearchResponse.swift
//  
//
//  Created by Vladislav Fitc on 04/05/2020.
//

import Foundation

public struct RuleSearchResponse: Codable {

  /// A list of Hit.
  public let hits: [Hit]

  /// Number of hits.
  public let nbHits: Int

  /// Returned page number.
  public let page: Int

  /// Total number of pages.
  public let nbPages: Int

}
