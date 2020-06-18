//
//  SynonymQuery.swift
//  
//
//  Created by Vladislav Fitc on 11/05/2020.
//

import Foundation

public struct SynonymQuery {

  /// Full text query.
  /// - Engine default: ""
  public var query: String?

  /// The page to fetch when browsing through several pages of results. This value is zero-based.
  /// - Engine default: 0
  public var page: Int?

  /// The number of synonyms to return for each call.
  /// Engine default: 100
  public var hitsPerPage: Int?

  /// Restrict the search to a specific SynonymType.
  /// Engine default: []
  public var synonymTypes: [SynonymType]?

  public init() {}

}

extension SynonymQuery: ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    self.query = value
  }

}

extension SynonymQuery: Builder {}

extension SynonymQuery: Codable {

  enum CodingKeys: String, CodingKey {
    case query
    case page
    case hitsPerPage
    case synonymTypes = "type"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.query = try container.decodeIfPresent(forKey: .query)
    self.page = try container.decodeIfPresent(forKey: .page)
    self.hitsPerPage = try container.decodeIfPresent(forKey: .hitsPerPage)
    let rawSynonymTypes: String? = try container.decodeIfPresent(forKey: .synonymTypes)
    self.synonymTypes = rawSynonymTypes.flatMap { $0.split(separator: ",").map(String.init).compactMap(SynonymType.init) }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(query, forKey: .query)
    try container.encodeIfPresent(page, forKey: .page)
    try container.encodeIfPresent(hitsPerPage, forKey: .hitsPerPage)
    let rawSynonymTypes: String? = synonymTypes.flatMap { $0.map(\.rawValue).joined(separator: ",") }
    try container.encodeIfPresent(rawSynonymTypes, forKey: .synonymTypes)
  }

}
