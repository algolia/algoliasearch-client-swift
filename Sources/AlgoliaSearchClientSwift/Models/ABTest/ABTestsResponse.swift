//
//  ABTestsResponse.swift
//  
//
//  Created by Vladislav Fitc on 28/05/2020.
//

import Foundation

public struct ABTestsResponse: Codable {

  /// Number of ABTest returned.
  public let count: Int

  /// Total number of ABTest that can be fetched.
  public let total: Int

  /// List of AB tests
  public let abTests: [ABTestResponse]?

  enum CodingKeys: String, CodingKey {
    case count
    case total
    case abTests = "abtests"
  }

}
