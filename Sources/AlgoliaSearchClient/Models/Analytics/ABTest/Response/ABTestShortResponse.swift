//
//  ABTestShortResponse.swift
//  
//
//  Created by Vladislav Fitc on 28/05/2020.
//

import Foundation

/// Short version of ABTestResponse.
public struct ABTestShortResponse {

  /// ABTestID of the ABTest test.
  public let abTestID: ABTestID

  /// The base index Variant.
  public let variantA: Variant

  /// The index Variant to test against.
  public let variantB: Variant

}

extension ABTestShortResponse: Codable {

  enum CodingKeys: String, CodingKey {
    case abTestID = "id"
    case variants
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.abTestID = try container.decode(forKey: .abTestID)
    let variants: [Variant] = try container.decode(forKey: .variants)
    self.variantA = variants[0]
    self.variantB = variants[1]
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(abTestID, forKey: .abTestID)
    try container.encode([variantA, variantB], forKey: .variants)
  }

}

extension ABTestShortResponse {

  /// Variant of an ABTest
  public struct Variant: Codable {

    /// Index name.
    public let indexName: IndexName

    /// Percentage of the traffic that should be going to the variant.
    /// The sum of the percentage between ABTest.variantA and ABTest.variantB should be equal to 100.
    public let trafficPercentage: Int

    /// Description of the variant. This is useful when seeing the results in the dashboard or via the API.
    public let description: String?

    public init(indexName: IndexName,
                trafficPercentage: Int,
                customSearchParameters: Query? = nil,
                description: String? = nil) {
      self.indexName = indexName
      self.trafficPercentage = trafficPercentage
      self.description = description
    }

    enum CodingKeys: String, CodingKey {
      case indexName
      case trafficPercentage = "percentage"
      case description
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.indexName = try container.decode(forKey: .indexName)
      self.trafficPercentage = try container.decode(forKey: .trafficPercentage)
      self.description = try container.decodeIfPresent(forKey: .description)
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(indexName, forKey: .indexName)
      try container.encode(trafficPercentage, forKey: .trafficPercentage)
      try container.encodeIfPresent(description, forKey: .description)
    }

  }

}
