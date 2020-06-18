//
//  ABTest+Variant.swift
//  
//
//  Created by Vladislav Fitc on 28/05/2020.
//

import Foundation

extension ABTest {

  /// Variant of an ABTest
  public struct Variant: Codable {

    /// Index name.
    public let indexName: IndexName

    /// Percentage of the traffic that should be going to the variant.
    /// The sum of the percentage between ABTest.variantA and ABTest.variantB should be equal to 100.
    public let trafficPercentage: Int

    /// Applies search parameters on a variant. This can only be used if the two variants are using the same index.
    public let customSearchParameters: Query?

    /// Description of the variant. This is useful when seeing the results in the dashboard or via the API.
    public let description: String?

    public init(indexName: IndexName,
                trafficPercentage: Int,
                customSearchParameters: Query? = nil,
                description: String? = nil) {
      self.indexName = indexName
      self.trafficPercentage = trafficPercentage
      self.customSearchParameters = customSearchParameters
      self.description = description
    }

    enum CodingKeys: String, CodingKey {
      case indexName = "index"
      case trafficPercentage
      case customSearchParameters
      case description
    }

  }

}
