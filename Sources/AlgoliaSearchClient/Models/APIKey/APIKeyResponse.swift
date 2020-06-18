//
//  APIKeyResponse.swift
//  
//
//  Created by Vladislav Fitc on 09/04/2020.
//

import Foundation

public struct APIKeyResponse {

  /// The APIKey value
  public let key: APIKey

  /// The date at which the APIKey has been created.
  public let createdAt: Date

  /// The list of permissions ACL the key contains.
  public let ACLs: [ACL]

  /// The timestamp of the date at which the [APIKey] expires. (0 means it will not expire automatically).
  public let validity: TimeInterval

  /// The maximum number of hits an [APIKey] can retrieve in one call.
  public let maxHitsPerQuery: Int?

  /// The maximum number of API calls allowed from an IP address per hour.
  public let maxQueriesPerIPPerHour: Int?

  /// The list of targeted indices, if any.
  public let indices: [IndexName]?

  /// The list of referers
  public let referers: [String]?

  /// The Query parameters
  public let query: String?

  /// The description of the APIKey
  public let description: String?

}

extension APIKeyResponse: Codable {

  enum CodingKeys: String, CodingKey {
    case key = "value"
    case createdAt
    case ACLs = "acl"
    case validity
    case maxHitsPerQuery
    case maxQueriesPerIPPerHour
    case indices = "indexes"
    case referers
    case query = "queryParameters"
    case description
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.key = try container.decode(forKey: .key)
    self.createdAt = try container.decode(forKey: .createdAt)
    self.ACLs = try container.decode(forKey: .ACLs)
    self.validity = try container.decode(forKey: .validity)
    self.maxHitsPerQuery = try container.decodeIfPresent(forKey: .maxHitsPerQuery)
    self.maxQueriesPerIPPerHour = try container.decodeIfPresent(forKey: .maxQueriesPerIPPerHour)
    self.indices = try container.decodeIfPresent(forKey: .indices)
    self.referers = try container.decodeIfPresent(forKey: .referers)
    self.query = try container.decodeIfPresent(forKey: .query)
    self.description = try container.decodeIfPresent(forKey: .description)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(key, forKey: .key)
    try container.encode(createdAt, forKey: .createdAt)
    try container.encode(ACLs, forKey: .ACLs)
    try container.encodeIfPresent(validity, forKey: .validity)
    try container.encodeIfPresent(maxHitsPerQuery, forKey: .maxHitsPerQuery)
    try container.encodeIfPresent(maxQueriesPerIPPerHour, forKey: .maxQueriesPerIPPerHour)
    try container.encodeIfPresent(indices, forKey: .indices)
    try container.encodeIfPresent(referers, forKey: .referers)
    try container.encodeIfPresent(query, forKey: .query)
    try container.encodeIfPresent(description, forKey: .description)
  }

}
