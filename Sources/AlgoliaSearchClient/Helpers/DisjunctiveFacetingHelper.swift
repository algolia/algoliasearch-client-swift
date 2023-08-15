//
//  DisjunctiveFacetingHelper.swift
//  
//
//  Created by Vladislav Fitc on 19/10/2022.
//

import Foundation

/// Helper making multiple queries for disjunctive faceting
/// and merging the multiple search responses into a single one with
/// combined facets information
struct DisjunctiveFacetingHelper {

  let query: Query
  let refinements: [Attribute: [String]]
  let disjunctiveFacets: Set<Attribute>

  /// Build filters SQL string from the provided refinements and disjunctive facets set
  func buildFilters(excluding excludedAttribute: Attribute?) -> String {
    String(
      refinements
        .sorted(by: { $0.key.rawValue < $1.key.rawValue })
        .filter { (name: Attribute, values: [String]) in
        name != excludedAttribute && !values.isEmpty
      }.map { (name: Attribute, values: [String]) in
        let facetOperator = disjunctiveFacets.contains(name) ? " OR " : " AND "
        let expression = values
          .map { value in """
          "\(name)":"\(value)"
          """
          }
          .joined(separator: facetOperator)
        return "(\(expression))"
      }.joined(separator: " AND ")
    )
  }

  /// Get applied disjunctive facet values for provided attribute
  func appliedDisjunctiveFacetValues(for attribute: Attribute) -> Set<String> {
    guard disjunctiveFacets.contains(attribute) else {
      return []
    }
    return refinements[attribute].flatMap(Set.init) ?? []
  }

  /// Build search queries to fetch the necessary facets information for disjunctive faceting
  /// If the disjunctive facets set is empty, makes a single request with applied conjunctive filters
  func makeQueries() -> [Query] {
    var queries = [Query]()

    var mainQuery = query
    mainQuery.filters = buildFilters(excluding: .none)

    queries.append(mainQuery)

    disjunctiveFacets
      .sorted(by: { $0.rawValue < $1.rawValue })
      .forEach { disjunctiveFacet in
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

  /// Merge received search responses into single one with combined facets information
  func mergeResponses(_ responses: [SearchResponse], keepSelectedEmptyFacets: Bool = true) throws -> SearchResponse {
    guard var mainResponse = responses.first else {
      throw DisjunctiveFacetingError.emptyResponses
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

}

public enum DisjunctiveFacetingError: LocalizedError {

  case emptyResponses

  var localizedDescription: String {
    switch self {
    case .emptyResponses:
      return "Unexpected empty search responses list. At least one search responses might be present."
    }
  }

}
