//
//  PersonalizationStrategy.swift
//  
//
//  Created by Vladislav Fitc on 27/05/2020.
//

import Foundation

public struct PersonalizationStrategy {

  /// Events scoring saved on the API.
  public let eventsScoring: [EventScoring]

  /// Facets scoring saved on the API.
  public let facetsScoring: [FacetScoring]

  /// Personalization impact.
  public let personalizationImpact: Int

  public init(eventsScoring: [EventScoring],
              facetsScoring: [FacetScoring],
              personalizationImpact: Int) {
    self.eventsScoring = eventsScoring
    self.facetsScoring = facetsScoring
    self.personalizationImpact = personalizationImpact
  }

}

extension PersonalizationStrategy: Codable {

  enum CodingKeys: String, CodingKey {
    case eventsScoring
    case facetsScoring
    case personalizationImpact
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.eventsScoring = try container.decode(forKey: .eventsScoring)
    self.facetsScoring = try container.decode(forKey: .facetsScoring)
    self.personalizationImpact = try container.decode(forKey: .personalizationImpact)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(eventsScoring, forKey: .eventsScoring)
    try container.encode(facetsScoring, forKey: .facetsScoring)
    try container.encode(personalizationImpact, forKey: .personalizationImpact)
  }

}
