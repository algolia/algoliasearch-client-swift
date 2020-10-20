//
//  DeleteByQuery.swift
//  
//
//  Created by Vladislav Fitc on 26/03/2020.
//

import Foundation

/// Proxy for a Query object keeping visible fields for deletion

public struct DeleteByQuery {

  var query: Query = .empty

  /**
   Filter the query with numeric, facet and/or tag filters.
   - Engine default: ""
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/filters/?language=swift)
   */
  public var filters: String? {

    get {
      return query.filters
    }

    set {
      query.filters = newValue
    }

  }

  /**
   Filter hits by facet value.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/facetFilters/?language=swift)
   */
  public var facetFilters: FiltersStorage? {

    get {
      return query.facetFilters
    }

    set {
      query.facetFilters = newValue
    }

  }

  /**
   Filter on numeric attributes.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/numericFilters/?language=swift)
   */
  public var numericFilters: FiltersStorage? {

    get {
      return query.numericFilters
    }

    set {
      query.numericFilters = newValue
    }

  }

  /**
   Filter hits by tags.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/tagFilters/?language=swift)
   */
  public var tagFilters: FiltersStorage? {

    get {
      return query.tagFilters
    }

    set {
      query.tagFilters = newValue
    }

  }

  /**
   Search for entries around a central geolocation, enabling a geo search within a circular area.
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/aroundLatLng/?language=swift)
   */
  public var aroundLatLng: Point? {

    get {
      return query.aroundLatLng
    }

    set {
      query.aroundLatLng = newValue
    }

  }

  /**
   Define the maximum radius for a geo search (in meters).
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/aroundRadius/?language=swift)
   */
  public var aroundRadius: AroundRadius? {

    get {
      return query.aroundRadius
    }

    set {
      query.aroundRadius = newValue
    }

  }

  /**
   Precision of geo search (in meters), to add grouping by geo location to the ranking formula.
   - Engine default: 1
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/aroundPrecision/?language=swift)
   */
  public var aroundPrecision: [AroundPrecision]? {

    get {
      return query.aroundPrecision
    }

    set {
      query.aroundPrecision = newValue
    }

  }

  /**
   Search inside a rectangular area (in geo coordinates).
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/insideBoundingBox/?language=swift)
   */
  public var insideBoundingBox: [BoundingBox]? {

    get {
      return query.insideBoundingBox
    }

    set {
      query.insideBoundingBox = newValue
    }

  }

  /**
   Search inside a polygon (in geo coordinates).
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/insidePolygon/?language=swift)
   */
  public var insidePolygon: [Polygon]? {

    get {
      return query.insidePolygon
    }

    set {
      query.insidePolygon = newValue
    }

  }

  public init() {
  }

}

extension DeleteByQuery: Codable {

  public init(from decoder: Decoder) throws {
    query = try Query(from: decoder)
  }

  public func encode(to encoder: Encoder) throws {
    try query.encode(to: encoder)
  }

}

extension DeleteByQuery: URLEncodable {

  public var urlEncodedString: String {
    return query.urlEncodedString
  }

}

extension DeleteByQuery: Builder {}
