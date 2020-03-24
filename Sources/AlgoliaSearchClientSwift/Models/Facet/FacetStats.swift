//
//  FacetStats.swift
//  
//
//  Created by Vladislav Fitc on 19/03/2020.
//

import Foundation

/// Statistics for a numerical facet.

public struct FacetStats: Codable {

  /// The minimum value.
  public let min: Double

  /// The maximum value.
  public let max: Double

  /// The average of all values.
  public let avg: Double

  /// The sum of all values.
  public let sum: Double

}
