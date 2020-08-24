//
//  PlacesQuery.swift
//  
//
//  Created by Vladislav Fitc on 12/04/2020.
//

import Foundation

public struct PlacesQuery {

  /// The query to match places by name.
  public var query: String?

  /// Restrict the search results to a specific type.
  public var type: PlaceType?

  /// If specified, restrict the search results to a specific list of countries.
  /// - Engine default: Search on the whole planet.
  public var countries: [Country]?

  /// Force to first search around a specific latitude longitude.
  public var aroundLatLng: Point?

  /// Whether or not to first search around the geolocation of the user found via his IP address.
  /// - Engine default: true
  public var aroundLatLngViaIP: Bool?

  /// Radius in meters to search around the latitude/longitude.
  /// Otherwise a default radius is automatically computed given the area density.
  public var aroundRadius: AroundRadius?

  /// Controls whether the _rankingInfo object should be included in the hits.
  /// - Engine default: false
  public var getRankingInfo: Bool?

  /// Specifies how many results you want to retrieve per search.
  /// - Engine default: 20
  public var hitsPerPage: Int?

  /// Specifies the language of the results.
  ///
  /// When set to nil, engine returns the results in all available languages
  /// - Remark: Cannot be set explicitly. To set the language of places query, set the `language` parameter of `PlaceClients.search` method.
  /// - Engine default: nil
  internal var language: Language?

  public init(_ query: String? = nil) {
    self.query = query
  }

}

extension PlacesQuery: Builder {}

extension PlacesQuery: ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    self.init(value)
  }

}

extension PlacesQuery: Codable {

  enum CodingKeys: String, CodingKey {
    case query
    case type
    case countries
    case aroundLatLng
    case aroundLatLngViaIP
    case aroundRadius
    case getRankingInfo
    case hitsPerPage
    case language
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    query = try container.decodeIfPresent(forKey: .query)
    type = try container.decodeIfPresent(forKey: .type)
    countries = try container.decodeIfPresent(forKey: .countries)
    aroundLatLng = try container.decodeIfPresent(forKey: .aroundLatLng)
    aroundLatLngViaIP = try container.decodeIfPresent(forKey: .aroundLatLngViaIP)
    aroundRadius = try container.decodeIfPresent(forKey: .aroundRadius)
    getRankingInfo = try container.decodeIfPresent(forKey: .getRankingInfo)
    hitsPerPage = try container.decodeIfPresent(forKey: .hitsPerPage)
    language = try container.decodeIfPresent(forKey: .language)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(query, forKey: .query)
    try container.encodeIfPresent(type, forKey: .type)
    try container.encodeIfPresent(countries, forKey: .countries)
    try container.encodeIfPresent(aroundLatLng, forKey: .aroundLatLng)
    try container.encodeIfPresent(aroundLatLngViaIP, forKey: .aroundLatLngViaIP)
    try container.encodeIfPresent(aroundRadius, forKey: .aroundRadius)
    try container.encodeIfPresent(getRankingInfo, forKey: .getRankingInfo)
    try container.encodeIfPresent(hitsPerPage, forKey: .hitsPerPage)
    try container.encodeIfPresent(language, forKey: .language)
  }

}
