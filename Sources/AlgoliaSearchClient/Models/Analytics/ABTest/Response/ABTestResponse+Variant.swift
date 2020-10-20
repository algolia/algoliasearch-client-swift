//
//  ABTestReponse+Variant.swift
//  
//
//  Created by Vladislav Fitc on 28/05/2020.
//

import Foundation

extension ABTestResponse {

  public struct Variant: Codable {

    /// Distinct click count for the variant.
    public let clickCount: Int

    /// Distinct conversion count for the variant.
    public let conversionCount: Int

    public let description: String

    public let indexName: IndexName

    public let trafficPercentage: Int

    /// Conversion rate for the variant.
    public let conversionRate: Double?

    public let noResultCount: Int?

    /// Average click position for the variant.
    public let averageClickPosition: Double?

    public let searchCount: Int?

    public let trackedSearchCount: Int?

    public let userCount: Int?

    /// Click through rate for the variant.
    public let clickThroughRate: Double?

    public let customSearchParameters: Query?

    enum CodingKeys: String, CodingKey {
      case clickCount
      case conversionCount
      case description
      case indexName = "index"
      case trafficPercentage
      case conversionRate
      case noResultCount
      case averageClickPosition
      case searchCount
      case trackedSearchCount
      case userCount
      case clickThroughRate
      case customSearchParameters
    }

  }

}
