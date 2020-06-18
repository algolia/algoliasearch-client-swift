//
//  APIKeyParams.swift
//  
//
//  Created by Vladislav Fitc on 08/04/2020.
//

import Foundation

public struct APIKeyParameters {

  /// Set of permissions ACL associated to an APIKey.
  public var ACLs: [ACL]

  /// A Unix timestamp used to define the expiration date of an APIKey.
  public var validity: TimeInterval?

  /**
   Specify the maximum number of hits an [APIKey] can retrieve in one call.
   This parameter can be used to protect you from attempts at retrieving your entire index contents by massively
   querying the index.
   */
  public var maxHitsPerQuery: Int?

  /**
   Specify the maximum number of API calls allowed from an IP address per hour.
   Each time an API call is performed with an APIKey, a check is performed.
   If the IP at the source of the call did more than this number of calls in the last hour, a 429 code is returned.
   This parameter can be used to protect you from attempts at retrieving your entire index contents by massively
   querying the index.
   */
  public var maxQueriesPerIPPerHour: Int?

  /**
   Specify the list of targeted indices. You can target all indices starting with a prefix or ending with a
   suffix using the ‘*’ character.
   For example, “dev_*” matches all indices starting with “dev_” and “*_dev” matches all indices ending with “_dev”.
   */
  public var indices: [IndexName]?

  /**
   Specify the list of referers. You can target all referers starting with a prefix, ending with a suffix using
   the character `*`. For example, "https://algolia.com/`*`" matches all referers starting with
   "https://algolia.com/" and "`*`.algolia.com" matches all referers ending with ".algolia.com".
   If you want to allow the domain algolia.com you can use "`*`algolia.com/`*`".
   */
  public var referers: [String]?

  /**
   Specify the Query parameters. You can force the Query parameters for a Query using the url string format.
   Example: “typoTolerance=strict&ignorePlurals=false”.
   */
  public var query: Query?

  /**
   Specify a description of the APIKey. Used for informative purposes only.
   It has impact on the functionality of the APIKey.
   */
  public var description: String?

  /**
   IPv4 network allowed to use the generated key. This is used for more protection against API key leaking and reuse.
   - Note: Уou can only provide a single source, but you can specify a range of IPs (e.g., 192.168.1.0/24).
   */
  public var restrictSources: String?

  public init(ACLs: [ACL]) {
    self.ACLs = ACLs
  }

}

extension APIKeyParameters: Builder {}

extension APIKeyParameters {

  private var queryWithAppliedRestrictSources: Query? {
    guard let restrictSources = restrictSources else { return query }
    var query = self.query ?? .init()
    var customParameters = query.customParameters ?? [:]
    customParameters[CodingKeys.restrictSources.rawValue] = .init(restrictSources)
    query.customParameters = customParameters
    return query
  }

}

extension APIKeyParameters: Codable {

  enum CodingKeys: String, CodingKey {
    case ACLs = "acl"
    case validity
    case maxHitsPerQuery
    case maxQueriesPerIPPerHour
    case indices = "indexes"
    case referers
    case query = "queryParameters"
    case description
    case restrictSources
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.ACLs = try container.decode(forKey: .ACLs)
    self.validity = try container.decodeIfPresent(forKey: .validity)
    self.maxHitsPerQuery = try container.decodeIfPresent(forKey: .maxHitsPerQuery)
    self.maxQueriesPerIPPerHour = try container.decodeIfPresent(forKey: .maxQueriesPerIPPerHour)
    self.indices = try container.decodeIfPresent(forKey: .indices)
    self.referers = try container.decodeIfPresent(forKey: .referers)
    self.query = try container.decodeIfPresent(forKey: .query)
    self.description = try container.decodeIfPresent(forKey: .description)

  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(ACLs, forKey: .ACLs)
    try container.encodeIfPresent(validity, forKey: .validity)
    try container.encodeIfPresent(maxHitsPerQuery, forKey: .maxHitsPerQuery)
    try container.encodeIfPresent(maxQueriesPerIPPerHour, forKey: .maxQueriesPerIPPerHour)
    try container.encodeIfPresent(indices, forKey: .indices)
    try container.encodeIfPresent(referers, forKey: .referers)
    try container.encodeIfPresent(queryWithAppliedRestrictSources?.urlEncodedString, forKey: .query)
    try container.encodeIfPresent(description, forKey: .description)
  }

}
