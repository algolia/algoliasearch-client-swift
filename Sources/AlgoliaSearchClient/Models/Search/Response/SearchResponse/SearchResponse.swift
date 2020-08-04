//
//  SearchResponse.swift
//  
//
//  Created by Vladislav Fitc on 17.02.2020.
//

import Foundation

public struct SearchResponse {

  /**
   The hits returned by the search. Hits are ordered according to the ranking or sorting of the index being queried.
   Hits are made of the schemaless JSON objects that you stored in the index.
   */
  public var hits: [Hit<JSON>]

  /**
   The number of hits matched by the query.
   */
  public var nbHits: Int?

  /**
   Index of the current page (zero-based). See the Query.page search parameter.
  - Not returned if you use offset/length for pagination.
  */
  public var page: Int?

  /**
   The maximum number of hits returned per page. See the Query.hitsPerPage search parameter.
  - Not returned if you use offset & length for pagination.
  */
  public var hitsPerPage: Int?

  /**
   Alternative to page (zero-based). Is returned only when Query.offset Query.length is specified.
  */
  public var offset: Int?

  /**
   Alternative to hitsPerPageOrNull (zero-based). Is returned only when Query.offset Query.length is specified.
  */
  public var length: Int?

  /**
   Array of userData object. Only returned if at least one query rule containing a custom userData
   consequence was applied.
  */
  public var userData: [JSON]?

  /**
   The number of returned pages. Calculation is based on the total number of hits (nbHits) divided by the number of
   hits per page (hitsPerPage), rounded up to the nearest integer.
  - Not returned if you use offset & length for pagination.
  */
  public var nbPages: Int?

  /**
   Time the server took to process the request, in milliseconds. This does not include network time.
  */
  public var processingTimeMS: TimeInterval?

  /**
   Whether the nbHits is exhaustive (true) or approximate (false). An approximation is done when the query takes
   more than 50ms to be processed (this can happen when using complex filters on millions on records).
   - See the related [discussion](https://www.algolia.com/doc/faq/index-configuration/my-facet-and-hit-counts-are-not-accurate/)
  */
  public var exhaustiveNbHits: Bool?

  /**
   Whether the facet count is exhaustive (true) or approximate (false).
   - See the related [discussion](https://www.algolia.com/doc/faq/index-configuration/my-facet-and-hit-counts-are-not-accurate/).
   */
  public var exhaustiveFacetsCount: Bool?

  /**
   An echo of the query text. See the Query.query search parameter.
  */
  public var query: String?

  /**
   A markup text indicating which parts of the original query have been removed in order to retrieve a non-empty result set.
   - The removed parts are surrounded by <em> tags.
   - Only returned when Query.removeWordsIfNoResults or Settings.removeWordsIfNoResults is set to RemoveWordIfNoResults.LastWords or RemoveWordIfNoResults.FirstWords.
   */
  public var queryAfterRemoval: String?

  /**
   A url-encoded string of all Query parameters.
  */
  public var params: String?

  /**
   Used to return warnings about the query.
  */
  public var message: String?

  /**
   The computed geo location.
  - Only returned when Query.aroundLatLngViaIP or Query.aroundLatLng is set.
  */
  public var aroundLatLng: Point?

  /**
   The automatically computed radius. For legacy reasons, this parameter is a string and not an integer.
  - Only returned for geo queries without an explicitly specified Query.aroundRadius.
  */
  public var automaticRadius: Double?

  /**
   Actual host name of the server that processed the request. Our DNS supports automatic failover and load
   balancing, so this may differ from the host name used in the request.
   - Returned only if Query.getRankingInfo is set to true.
  */
  public var serverUsed: String?

  /**
   Index name used for the query. In case of A/B test, the index targeted isn’t always the index used by the query.
   - Returned only if Query.getRankingInfo is set to true.
  */
  public var indexUsed: IndexName?

  /**
   In case of A/B test, reports the variant ID used. The variant ID is the position in the array of variants
   (starting at 1).
   - Returned only if [Query.getRankingInfo] is set to true.
  */
  public var abTestVariantID: Int?

  /**
   The query string that will be searched, after
    [normalization](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/handling-natural-languages-nlp/in-depth/normalization/#what-is-normalization).
   - Normalization includes removing stop words (if Query.removeStopWords or Settings.removeStopWords is enabled),
    and transforming portions of the query string into phrase queries
    (see Query.advancedSyntax or Settings.advancedSyntax).
   - Returned only if Query.getRankingInfo is set to true.
   */
  public var parsedQuery: String?

  /**
   A mapping of each facet name to the corresponding facet counts.
   - Returned only if Query.facets is non-empty.
  */
  public var facets: [Attribute: [Facet]]? {

    get {
      return facetsStorage?.storage
    }

    set {
      facetsStorage = newValue.flatMap(FacetsStorage.init(storage:))
    }

  }
  var facetsStorage: FacetsStorage?

  /**
   A mapping of each facet name to the corresponding facet counts for disjunctive facets.
   - Returned only by the EndpointSearch.advancedSearch method.
   - [Documentation](https://www.algolia.com/doc/guides/building-search-ui/going-further/backend-search/how-to/faceting/?language=kotlin#conjunctive-and-disjunctive-faceting)
   */
  public var disjunctiveFacets: [Attribute: [Facet]]? {

    get {
      return disjunctiveFacetsStorage?.storage
    }

    set {
      disjunctiveFacetsStorage = newValue.flatMap(FacetsStorage.init(storage:))
    }

  }
  var disjunctiveFacetsStorage: FacetsStorage?

  /**
   * Statistics for numerical facets.
   - Returned only if Query.facets is non-empty and at least one of the returned facets contains numerical values.
   */
  public var facetStats: [Attribute: FacetStats]? {

    get {
      return facetStatsStorage?.storage
    }

    set {
      facetStatsStorage = newValue.flatMap(FacetStatsStorage.init(storage:))
    }

  }
  var facetStatsStorage: FacetStatsStorage?

  /**
   Returned only by the EndpointSearch.browse method.
  */
  public var cursor: Cursor?

  public var indexName: IndexName?

  public var processed: Bool?

  /**
   Identifies the query uniquely. Can be used by InsightsEvent.
  */
  public var queryID: QueryID?

  /**
   A mapping of each facet name to the corresponding facet counts for hierarchical facets.
   - Returned only by the [EndpointSearch.advancedSearch] method, only if a [FilterGroup.And.Hierarchical] is used.
  */
  public var hierarchicalFacets: [Attribute: [Facet]]? {

    get {
      return hierarchicalFacetsStorage?.storage
    }

    set {
      hierarchicalFacetsStorage = newValue.flatMap(FacetsStorage.init(storage:))
    }

  }
  var hierarchicalFacetsStorage: FacetsStorage?

  /**
   Meta-information as to how the query was processed.
  */
  public var explain: Explain?
  
  public init(hits: [Hit<JSON>] = []) {
    self.hits = hits
  }
  
}

extension SearchResponse: Builder {}

public extension SearchResponse {

  func extractHits<T: Decodable>() throws -> [T] {
    let hitsData = try JSONEncoder().encode(hits.map(\.object))
    return try JSONDecoder().decode([T].self, from: hitsData)
  }

  /// Returns the position (0-based) within the hits result list of the record matching against the given objectID.
  /// If the objectID is not found, nil is returned.
  func getPositionOfObject(withID objectID: ObjectID) -> Int? {
    return hits.firstIndex { $0.objectID == objectID }
  }

}
