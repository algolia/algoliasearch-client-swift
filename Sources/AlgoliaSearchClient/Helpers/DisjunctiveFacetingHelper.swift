//
//  DisjunctiveFacetingHelper.swift
//  
//
//  Created by Vladislav Fitc on 19/10/2022.
//

import Foundation

struct DisjunctiveFacetingHelper {

  let query: Query
  let refinements: [Attribute: [String]]
  let disjunctiveFacets: [Attribute]

  init(query: Query, refinements: [Attribute: [String]], disjunctiveFacets: [Attribute]) {
    self.query = query
    self.refinements = refinements
    self.disjunctiveFacets = disjunctiveFacets
  }

  func buildFilters(excluding excludedAttribute: Attribute?) -> String {
    String(
      refinements
        .sorted(by: { $0.key.rawValue < $1.key.rawValue })
        .filter { (name: Attribute, values: [String]) in
        name != excludedAttribute && !values.isEmpty
      }.map { (name: Attribute, values: [String]) in
        let facetOperator = disjunctiveFacets.contains(name) ? " OR " : " AND "
        let expression = values
          .sorted(by: { $0 < $1 })
          .map { value in "\(name):\(value)" }
          .joined(separator: facetOperator)
        return "(\(expression))"
      }.joined(separator: " AND ")
    )
  }

  func appliedDisjunctiveFacetValues(for attribute: Attribute) -> Set<String> {
    guard disjunctiveFacets.contains(attribute) else {
      return []
    }
    return refinements[attribute].flatMap(Set.init) ?? []
  }

  func makeQueries() -> [Query] {
    var queries = [Query]()

    var mainQuery = query
    mainQuery.filters = buildFilters(excluding: .none)

    queries.append(mainQuery)

    disjunctiveFacets.forEach { disjunctiveFacet in
      var disjunctiveQuery = query
      disjunctiveQuery.facets = [disjunctiveFacet]
      disjunctiveQuery.filters = buildFilters(excluding: disjunctiveFacet)
      disjunctiveQuery.hitsPerPage = 0
      disjunctiveQuery.attributesToRetrieve = []
      disjunctiveQuery.attributesToHighlight = []
      disjunctiveQuery.attributesToSnippet = []
      disjunctiveQuery.analytics = false
      queries.append(disjunctiveQuery)
    }

    return queries
  }

  func mergeResponses(_ responses: [SearchResponse], keepSelectedFacets: Bool = true) throws -> SearchResponse {
    guard var mainResponse = responses.first else {
      throw Error.emptyResponses
    }

    let responsesForDisjunctiveFaceting = responses.dropFirst()

    var mergedDisjunctiveFacets = [Attribute: [Facet]]()
    var mergedFacetStats = mainResponse.facetStats ?? [:]
    var mergedExhaustiveFacetsCount = mainResponse.exhaustiveFacetsCount ?? true

    for result in responsesForDisjunctiveFaceting {
      // Merge facet values
      if let facetsPerAttribute = result.facets {
        for (attribute, facets) in facetsPerAttribute {
          // Complete facet values applied in the filters
          // but missed in the search response
          let missingFacets = appliedDisjunctiveFacetValues(for: attribute)
            .subtracting(facets.map(\.value))
            .map { Facet(value: $0, count: 0) }
          mergedDisjunctiveFacets[attribute] = facets + missingFacets
        }
      }
      // Merge facets stats
      if let facetStats = result.facetStats {
        mergedFacetStats.merge(facetStats) { _, last in last }
      }
      // If facet counts are not exhaustive, propagate this information to the main results.
      // Because disjunctive queries are less restrictive than the main query, it can happen that the main query
      // returns exhaustive facet counts, while the disjunctive queries do not.
      if let exhaustiveFacetsCount = result.exhaustiveFacetsCount {
        mergedExhaustiveFacetsCount = mergedExhaustiveFacetsCount && exhaustiveFacetsCount
      }
    }
    mainResponse.disjunctiveFacets = mergedDisjunctiveFacets
    mainResponse.facetStats = mergedFacetStats
    mainResponse.exhaustiveFacetsCount = mergedExhaustiveFacetsCount

    return mainResponse
  }

  enum Error: Swift.Error {
    case emptyResponses

    var localizedDescription: String {
      switch self {
      case .emptyResponses:
        return "Unexpected empty search responses list. At least one search responses might be present."
      }
    }
  }

}
