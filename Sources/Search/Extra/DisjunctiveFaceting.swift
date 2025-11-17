//
//  DisjunctiveFaceting.swift
//  AlgoliaSearchClient
//
//  Created by Algolia on 18/09/2024.
//

import Foundation

public struct SearchDisjunctiveFacetingResponse<T: Codable> {
    public let response: SearchResponse<T>
    public let disjunctiveFacets: [String: [String: Int]]
}

/// Helper making multiple queries for disjunctive faceting
/// and merging the multiple search responses into a single one with
/// combined facets information
struct DisjunctiveFacetingHelper {
    let query: SearchForHits
    let refinements: [String: [String]]
    let disjunctiveFacets: Set<String>

    /// Build filters SQL string from the provided refinements and disjunctive facets set
    func buildFilters(excluding excludedAttribute: String?) -> String {
        String(
            self.refinements
                .sorted(by: { $0.key < $1.key })
                .filter { (name: String, values: [String]) in
                    name != excludedAttribute && !values.isEmpty
                }.map { (name: String, values: [String]) in
                    let facetOperator = self.disjunctiveFacets.contains(name) ? " OR " : " AND "
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

    /// Build search queries to fetch the necessary facets information for disjunctive faceting
    /// If the disjunctive facets set is empty, makes a single request with applied conjunctive filters
    func buildQueries() -> [SearchQuery] {
        var queries = [SearchQuery]()

        var mainQuery = self.query
        mainQuery.filters = [
            mainQuery.filters,
            self.buildFilters(excluding: .none),
        ]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " AND ")

        queries.append(.searchForHits(mainQuery))

        self.disjunctiveFacets
            .sorted(by: { $0 < $1 })
            .forEach { disjunctiveFacet in
                var disjunctiveQuery = self.query
                disjunctiveQuery.facets = [disjunctiveFacet]
                disjunctiveQuery.filters = [
                    disjunctiveQuery.filters,
                    self.buildFilters(excluding: disjunctiveFacet),
                ]
                    .compactMap { $0 }
                    .filter { !$0.isEmpty }
                    .joined(separator: " AND ")
                disjunctiveQuery.hitsPerPage = 0
                disjunctiveQuery.attributesToRetrieve = []
                disjunctiveQuery.attributesToHighlight = []
                disjunctiveQuery.attributesToSnippet = []
                disjunctiveQuery.analytics = false
                queries.append(.searchForHits(disjunctiveQuery))
            }

        return queries
    }

    /// Get applied disjunctive facet values for provided attribute
    func appliedDisjunctiveFacetValues(for attribute: String) -> Set<String> {
        guard self.disjunctiveFacets.contains(attribute) else {
            return []
        }
        return self.refinements[attribute].flatMap(Set.init) ?? []
    }

    /// Merge received search responses into single one with combined facets information
    func mergeResponses<T: Codable>(
        _ responses: [SearchResponse<T>]
    ) throws -> SearchDisjunctiveFacetingResponse<T> {
        guard var mainResponse = responses.first else {
            throw DisjunctiveFacetingError.emptyResponses
        }

        let responsesForDisjunctiveFaceting = responses.dropFirst()

        var mergedDisjunctiveFacets = [String: [String: Int]]()
        var mergedFacetStats = mainResponse.facetsStats ?? [:]
        var mergedExhaustiveFacetsCount = mainResponse.exhaustive?.facetsCount ?? true

        for result in responsesForDisjunctiveFaceting {
            // Merge facet values
            if let facetsPerAttribute = result.facets {
                for (attribute, facets) in facetsPerAttribute {
                    // Complete facet values applied in the filters
                    // but missed in the search response
                    let missingFacets = self.appliedDisjunctiveFacetValues(for: attribute)
                        .subtracting(facets.keys)
                        .reduce(into: [String: Int]()) { acc, cur in acc[cur] = 0 }
                    mergedDisjunctiveFacets[attribute] = facets.merging(missingFacets) { current, _ in current }
                }
            }
            // Merge facets stats
            if let facetsStats = result.facetsStats {
                mergedFacetStats.merge(facetsStats) { _, last in last }
            }
            // If facet counts are not exhaustive, propagate this information to the main results.
            // Because disjunctive queries are less restrictive than the main query, it can happen that the main query
            // returns exhaustive facet counts, while the disjunctive queries do not.
            if let exhaustiveFacetsCount = result.exhaustive?.facetsCount {
                mergedExhaustiveFacetsCount = mergedExhaustiveFacetsCount && exhaustiveFacetsCount
            }
        }
        mainResponse.facetsStats = mergedFacetStats
        if mainResponse.exhaustive == nil {
            mainResponse.exhaustive = SearchExhaustive()
        }
        mainResponse.exhaustive?.facetsCount = mergedExhaustiveFacetsCount

        return SearchDisjunctiveFacetingResponse(
            response: mainResponse,
            disjunctiveFacets: mergedDisjunctiveFacets
        )
    }
}

public enum DisjunctiveFacetingError: Error, LocalizedError {
    case emptyResponses

    var localizedDescription: String {
        switch self {
        case .emptyResponses:
            "Unexpected empty search responses list. At least one search responses might be present."
        }
    }
}
