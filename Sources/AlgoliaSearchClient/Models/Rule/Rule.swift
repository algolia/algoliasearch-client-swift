//
//  Rule.swift
//  
//
//  Created by Vladislav Fitc on 04/05/2020.
//

import Foundation

public struct Rule {

  /// Unique identifier for the rule.
  public var objectID: ObjectID

  /// Conditions of the rule.
  public var conditions: [Condition]?

  /// Consequence of the rule.
  public var consequence: Consequence?

  /// Whether the rule is enabled. Disabled rules remain in the index, but are not applied at query time.
  public var isEnabled: Bool?

  ///  By default, rules are permanently valid
  ///  When validity periods are specified, the rule applies only during those periods;
  ///  it is ignored the rest of the time. The list must not be empty.
  public var validity: [TimeRange]?

  /// This field is intended for rule management purposes, in particular to ease searching for rules and
  /// presenting them to human readers. It is not interpreted by the API.
  public var description: String?

  public init(objectID: ObjectID) {
    self.objectID = objectID
  }

}

extension Rule: Builder {}

extension Rule: Codable {

  enum CodingKeys: String, CodingKey {
    case objectID
    case conditions
    case consequence
    case isEnabled = "enabled"
    case validity
    case description
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.objectID = try container.decode(forKey: .objectID)
    self.conditions = try container.decodeIfPresent(forKey: .conditions)
    self.consequence = try container.decodeIfPresent(forKey: .consequence)
    self.isEnabled = try container.decodeIfPresent(forKey: .isEnabled)
    self.validity = try container.decodeIfPresent(forKey: .validity)
    self.description = try container.decodeIfPresent(forKey: .description)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(objectID, forKey: .objectID)
    try container.encodeIfPresent(conditions, forKey: .conditions)
    try container.encodeIfPresent(consequence, forKey: .consequence)
    try container.encodeIfPresent(isEnabled, forKey: .isEnabled)
    try container.encodeIfPresent(validity, forKey: .validity)
    try container.encodeIfPresent(description, forKey: .description)
  }

}
