//
//  SearchResponse+Codable.swift
//
//
//  Created by Vladislav Fitc on 19/03/2020.
//

import Foundation

extension SearchResponse: Codable {
  enum CodingKeys: String, CodingKey {
    case hits
    case nbHits
    case page
    case hitsPerPage
    case offset
    case length
    case userData
    case nbPages
    case processingTimeMS
    case exhaustiveNbHits
    case exhaustiveFacetsCount
    case query
    case queryAfterRemoval
    case params
    case message
    case aroundLatLng
    case automaticRadius
    case serverUsed
    case indexUsed
    case abTestID
    case abTestVariantID
    case parsedQuery
    case facetsStorage = "facets"
    case disjunctiveFacetsStorage = "disjunctiveFacets"
    case facetStatsStorage = "facets_stats"
    case cursor
    case indexName = "index"
    case processed
    case queryID
    case hierarchicalFacetsStorage = "hierarchicalFacets"
    case explain
    case appliedRules
    case renderingContent
    case appliedRelevancyStrictness
    case nbSortedHits
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    hits = try container.decode(forKey: .hits)
    nbHits = try container.decodeIfPresent(forKey: .nbHits)
    page = try container.decodeIfPresent(forKey: .page)
    hitsPerPage = try container.decodeIfPresent(forKey: .hitsPerPage)
    offset = try container.decodeIfPresent(forKey: .offset)
    length = try container.decodeIfPresent(forKey: .length)
    userData = try container.decodeIfPresent(forKey: .userData)
    nbPages = try container.decodeIfPresent(forKey: .nbPages)
    processingTimeMS = try container.decodeIfPresent(forKey: .processingTimeMS)
    exhaustiveNbHits = try container.decodeIfPresent(forKey: .exhaustiveNbHits)
    exhaustiveFacetsCount = try container.decodeIfPresent(forKey: .exhaustiveFacetsCount)
    query = try container.decodeIfPresent(forKey: .query)
    queryAfterRemoval = try container.decodeIfPresent(forKey: .queryAfterRemoval)
    params = try container.decodeIfPresent(forKey: .params)
    message = try container.decodeIfPresent(forKey: .message)
    aroundLatLng = try container.decodeIfPresent(forKey: .aroundLatLng)
    let legacyAutomaticRadius: String? = try container.decodeIfPresent(forKey: .automaticRadius)
    automaticRadius = legacyAutomaticRadius.flatMap(Double.init)
    serverUsed = try container.decodeIfPresent(forKey: .serverUsed)
    indexUsed = try container.decodeIfPresent(forKey: .indexUsed)
    abTestID = try container.decodeIfPresent(forKey: .abTestID)
    abTestVariantID = try container.decodeIfPresent(forKey: .abTestVariantID)
    parsedQuery = try container.decodeIfPresent(forKey: .parsedQuery)
    facetsStorage = try container.decodeIfPresent(forKey: .facetsStorage)
    disjunctiveFacetsStorage = try container.decodeIfPresent(forKey: .disjunctiveFacetsStorage)
    facetStatsStorage = try container.decodeIfPresent(forKey: .facetStatsStorage)
    cursor = try container.decodeIfPresent(forKey: .cursor)
    indexName = try container.decodeIfPresent(forKey: .indexName)
    processed = try container.decodeIfPresent(forKey: .processed)
    queryID = try container.decodeIfPresent(forKey: .queryID)
    hierarchicalFacetsStorage = try container.decodeIfPresent(forKey: .hierarchicalFacetsStorage)
    explain = try container.decodeIfPresent(forKey: .explain)
    appliedRules = try container.decodeIfPresent(forKey: .appliedRules)
    renderingContent = try container.decodeIfPresent(forKey: .renderingContent)
    appliedRelevancyStrictness = try container.decodeIfPresent(forKey: .appliedRelevancyStrictness)
    nbSortedHits = try container.decodeIfPresent(forKey: .nbSortedHits)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(hits, forKey: .hits)
    try container.encodeIfPresent(nbHits, forKey: .nbHits)
    try container.encodeIfPresent(page, forKey: .page)
    try container.encodeIfPresent(hitsPerPage, forKey: .hitsPerPage)
    try container.encodeIfPresent(offset, forKey: .offset)
    try container.encodeIfPresent(length, forKey: .length)
    try container.encodeIfPresent(userData, forKey: .userData)
    try container.encodeIfPresent(nbPages, forKey: .nbPages)
    try container.encodeIfPresent(processingTimeMS, forKey: .processingTimeMS)
    try container.encodeIfPresent(exhaustiveNbHits, forKey: .exhaustiveNbHits)
    try container.encodeIfPresent(exhaustiveFacetsCount, forKey: .exhaustiveFacetsCount)
    try container.encodeIfPresent(query, forKey: .query)
    try container.encodeIfPresent(queryAfterRemoval, forKey: .queryAfterRemoval)
    try container.encodeIfPresent(params, forKey: .params)
    try container.encodeIfPresent(message, forKey: .message)
    try container.encodeIfPresent(aroundLatLng, forKey: .aroundLatLng)
    let legacyAutomaticRadius = automaticRadius.flatMap { "\($0)" }
    try container.encodeIfPresent(legacyAutomaticRadius, forKey: .automaticRadius)
    try container.encodeIfPresent(serverUsed, forKey: .serverUsed)
    try container.encodeIfPresent(indexUsed, forKey: .indexUsed)
    try container.encodeIfPresent(abTestID, forKey: .abTestID)
    try container.encodeIfPresent(abTestVariantID, forKey: .abTestVariantID)
    try container.encodeIfPresent(parsedQuery, forKey: .parsedQuery)
    try container.encodeIfPresent(facetsStorage, forKey: .facetsStorage)
    try container.encodeIfPresent(disjunctiveFacetsStorage, forKey: .disjunctiveFacetsStorage)
    try container.encodeIfPresent(facetStatsStorage, forKey: .facetStatsStorage)
    try container.encodeIfPresent(cursor, forKey: .cursor)
    try container.encodeIfPresent(indexName, forKey: .indexName)
    try container.encodeIfPresent(processed, forKey: .processed)
    try container.encodeIfPresent(queryID, forKey: .queryID)
    try container.encodeIfPresent(hierarchicalFacetsStorage, forKey: .hierarchicalFacetsStorage)
    try container.encodeIfPresent(explain, forKey: .explain)
    try container.encodeIfPresent(appliedRules, forKey: .appliedRules)
    try container.encodeIfPresent(renderingContent, forKey: .renderingContent)
    try container.encodeIfPresent(appliedRelevancyStrictness, forKey: .appliedRelevancyStrictness)
    try container.encodeIfPresent(nbSortedHits, forKey: .nbSortedHits)
  }
}
