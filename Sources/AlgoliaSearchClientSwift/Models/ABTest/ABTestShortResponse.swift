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
  let abTestID: ABTestID
  
  /// The base index Variant.
  let variantA: ABTest.Variant
  
  /// The index Variant to test against.
  let variantB: ABTest.Variant
  
}

extension ABTestShortResponse: Codable {
  
  enum CodingKeys: String, CodingKey {
    case abTestID = "id"
    case variants
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.abTestID = try container.decode(forKey: .abTestID)
    let variants: [ABTest.Variant] = try container.decode(forKey: .variants)
    self.variantA = variants[0]
    self.variantB = variants[1]
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(abTestID, forKey: .abTestID)
    try container.encode([variantA, variantB], forKey: .variants)
  }

  
}
