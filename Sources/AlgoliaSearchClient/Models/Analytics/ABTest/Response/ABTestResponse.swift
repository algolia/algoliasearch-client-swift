//
//  ABTestResponse.swift
//  
//
//  Created by Vladislav Fitc on 28/05/2020.
//

import Foundation

public struct ABTestResponse {

  /// ABTestID of the ABTest test.
  public let abTestID: ABTestID

  /// ABTest significance based on click data.
  /// Should be > 0.95 to be considered significant (no matter which variant is winning)
  public let clickSignificance: Double?

  /// ABTest significance based on conversion data.
  /// Should be > 0.95 to be considered significant (no matter which variant is winning
  public let conversionSignificance: Double?

  /// Time at which the ABTest  has been created.
  public let createdAt: Date

  /// Time at which the ABTest will automatically stop.
  public let endAt: Date

  /// Name of the ABTest.
  public let name: String

  /// Current ABTestStatus of the ABTest.
  public let status: ABTestStatus

  /// The base index ResponseVariant.
  public let variantA: Variant

  /// The index ResponseVariant to test against.
  public let variantB: Variant

}

extension ABTestResponse: Codable {

  enum CodingKeys: String, CodingKey {
    case abTestID
    case clickSignificance
    case conversionSignificance
    case createdAt
    case endAt
    case name
    case status
    case variants
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.abTestID = try container.decode(forKey: .abTestID)
    self.clickSignificance = try container.decodeIfPresent(forKey: .clickSignificance)
    self.conversionSignificance = try container.decodeIfPresent(forKey: .conversionSignificance)
    self.createdAt = try container.decode(forKey: .createdAt)
    if let endAt: Date = try? container.decode(forKey: .endAt, dateFormat: ABTest.endDateFormat) {
      self.endAt = endAt
    } else {
      self.endAt = try container.decode(forKey: .endAt)
    }
    self.name = try container.decode(forKey: .name)
    self.status = try container.decode(forKey: .status)
    let variants: [Variant] = try container.decode(forKey: .variants)
    self.variantA = variants[0]
    self.variantB = variants[1]
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(abTestID, forKey: .abTestID)
    try container.encode(clickSignificance, forKey: .clickSignificance)
    try container.encode(conversionSignificance, forKey: .conversionSignificance)
    try container.encode(createdAt, forKey: .createdAt)
    try container.encode(endAt, forKey: .endAt, dateFormat: ABTest.endDateFormat)
    try container.encode(name, forKey: .name)
    try container.encode(status, forKey: .status)
    try container.encode([variantA, variantB], forKey: .variants)
  }

}
