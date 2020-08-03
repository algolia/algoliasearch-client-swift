//
//  Query.swift
//  
//
//  Created by Vladislav Fitc on 17.02.2020.
//
// swiftlint:disable file_length

import Foundation

public struct Query: Equatable {

  // MARK: - Search

  /**
   The text to search in the index.
   - Engine default: ""
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/query/?language=swift)
  */
  public var query: String?

  /**
    Overrides the query parameter and performs a more generic search that can be used to find "similar" results.
    Engine default: ""
    [Documentation][https://www.algolia.com/doc/api-reference/api-parameters/similarQuery/?language=swift)
   */
  public var similarQuery: String?

  // MARK: - Advanced

  /**
   Enables de-duplication or grouping of results.
   - Engine default: 0
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/distinct/?language=swift)
   */
  public var distinct: Distinct?

  /**
   Retrieve detailed ranking information.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/getRankingInfo/?language=swift)
   */
  public var getRankingInfo: Bool?

  /**
   Enriches the API’s response with meta-information as to how the query was processed.
   It is possible to enable several ExplainModule independently.
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/_/?language=swift)
   */
  public var explainModules: [ExplainModule]?

  /**
   List of supported languages with their associated language ISO code.
   Provide an easy way to implement voice and natural languages best practices such as ignorePlurals,
   removeStopWords, removeWordsIfNoResults, analyticsTags and ruleContexts.
  */
  public var naturalLanguages: [Language]?

  // MARK: - Attributes

  /**
   Gives control over which attributes to retrieve and which not to retrieve.
   - Engine default: [*]
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/attributesToRetrieve/?language=swift)
   */
  public var attributesToRetrieve: [Attribute]?

  /**
   Restricts a given query to look in only a subset of your searchable attributes.
   - Engine default: all attributes in [Settings.searchableAttributes].
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/restrictSearchableAttributes/?language=swift)
   */
  public var restrictSearchableAttributes: [Attribute]?

  // MARK: - Filtering-Faceting

  /**
   Filter the query with numeric, facet and/or tag filters.
   - Engine default: ""
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/filters/?language=swift)
   */
  public var filters: String?

  /**
   Filter hits by facet value.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/facetFilters/?language=swift)
   */
  public var facetFilters: FiltersStorage?

  /**
   Create filters for ranking purposes, where records that match the filter are ranked highest.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/optionalFilters/?language=swift)
   */
  public var optionalFilters: FiltersStorage?

  /**
   Filter on numeric attributes.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/numericFilters/?language=swift)
   */
  public var numericFilters: FiltersStorage?

  /**
   Filter hits by tags.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/tagFilters/?language=swift)
   */
  public var tagFilters: FiltersStorage?

  /**
   Determines how to calculate the total score for filtering.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/sumOrFiltersScores/?language=swift)
   */
  public var sumOrFiltersScores: Bool?

  /**
   Facets to retrieve.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/facets/?language=swift)
   */
  public var facets: Set<Attribute>?

  /**
   Maximum number of facet values to return for each facet during a regular search.
   - Engine default: 100
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/maxValuesPerFacet/?language=swift)
   */
  public var maxValuesPerFacet: Int?

  /**
   Force faceting to be applied after de-duplication (via the Distinct setting).
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/facetingAfterDistinct/?language=swift)
   */
  public var facetingAfterDistinct: Bool?

  /**
   Controls how facet values are sorted.
   - Engine default: [SortFacetsBy.Count]
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/sortFacetValuesBy/?language=swift)
   */
  public var sortFacetsBy: SortFacetsBy?

  /**
   Maximum number of facet hits to return during a search for facet values.
   - Engine default: 10
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/maxFacetHits/?language=swift)
   */
  public var maxFacetHits: Int?

  // MARK: - Highlighting-snippeting

  /**
   List of attributes to highlight.
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/attributesToHighlight/?language=swift)
   */
  public var attributesToHighlight: [Attribute]?

  /**
   List of attributes to snippet, with an optional maximum number of words to snippet.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/attributesToSnippet/?language=swift)
   */
  public var attributesToSnippet: [Snippet]?

  /**
   The HTML name to insert before the highlighted parts in all highlight and snippet results.
   - Engine default: <em>
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/highlightPreTag/?language=swift)
   */
  public var highlightPreTag: String?

  /**
   The HTML name to insert after the highlighted parts in all highlight and snippet results.
   - Engine default: </em>
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/highlightPostTag/?language=swift)
   */
  public var highlightPostTag: String?

  /**
   String used as an ellipsis indicator when a snippet is truncated.
   - Engine default: "…" (U+2026, HORIZONTAL ELLIPSIS)
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/snippetEllipsisText/?language=swift)
   */
  public var snippetEllipsisText: String?

  /**
   Restrict highlighting and snippeting to items that matched the query.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/restrictHighlightAndSnippetArrays/?language=swift)
   */
  public var restrictHighlightAndSnippetArrays: Bool?

  // MARK: - Pagination

  /**
   Specify the page to retrieve.
   - Engine default: 0
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/page/?language=swift)
   */
  public var page: Int?

  /**
   Set the number of hits per page.
   - Engine default: 20
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/hitsPerPage/?language=swift)
   */
  public var hitsPerPage: Int?

  /**
   Specify the offset of the first hit to return.
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/offset/?language=swift)
   */
  public var offset: Int?

  /**
   Set the number of hits to retrieve (used only with offset).
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/length/?language=swift)
   */
  public var length: Int?

  // MARK: - Typos

  /**
   Minimum number of characters a word in the query name must contain to accept matches with 1 typo.
   - Engine default: 4
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/minWordSizefor1Typo/?language=swift)
   */
  public var minWordSizeFor1Typo: Int?

  /**
   Minimum number of characters a word in the query name must contain to accept matches with 2 typos.
   - Engine default: 8
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/minWordSizefor2Typos/?language=swift)
   */
  public var minWordSizeFor2Typos: Int?

  /**
   Controls whether typo tolerance is enabled and how it is applied.
   Engine defaults: true
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/typoTolerance/?language=swift)
   */
  public var typoTolerance: TypoTolerance?

  /**
   Whether to allow typos on numbers (“numeric tokens”) in the query name.
   - Engine default: true
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/allowTyposOnNumericTokens/?language=swift)
   */
  public var allowTyposOnNumericTokens: Bool?

  /**
   List of attributes on which you want to disable typo tolerance.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/disableTypoToleranceOnAttributes/?language=swift)
   */
  public var disableTypoToleranceOnAttributes: [Attribute]?

  // MARK: - Geo-Search

  /**
   Search for entries around a central geolocation, enabling a geo search within a circular area.
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/aroundLatLng/?language=swift)
   */
  public var aroundLatLng: Point?

  /**
   Whether to search entries around a given location automatically computed from the requester’s IP address.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/aroundLatLngViaIP/?language=swift)
   */
  public var aroundLatLngViaIP: Bool?

  /**
   Define the maximum radius for a geo search (in meters).
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/aroundRadius/?language=swift)
   */
  public var aroundRadius: AroundRadius?

  /**
   Precision of geo search (in meters), to add grouping by geo location to the ranking formula.
   - Engine default: 1
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/aroundPrecision/?language=swift)
   */
  public var aroundPrecision: [AroundPrecision]?

  /**
   Minimum radius (in meters) used for a geo search when [aroundRadius] is not set.
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/minimumAroundRadius/?language=swift)
   */
  public var minimumAroundRadius: Int?

  /**
   Search inside a rectangular area (in geo coordinates).
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/insideBoundingBox/?language=swift)
   */
  public var insideBoundingBox: [BoundingBox]?

  /**
   Search inside a polygon (in geo coordinates).
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/insidePolygon/?language=swift)
   */
  public var insidePolygon: [Polygon]?

  // MARK: - Query strategy

  /**
   Controls if and how query words are interpreted as [prefixes](https://www.algolia.com/doc/guides/textual-relevance/prefix-search/?language=swift).
   - Engine default: [QueryType.PrefixLast]
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/queryType/?language=swift)
   */
  public var queryType: QueryType?

  /**
   Selects a strategy to remove words from the query when it doesn’t match any hits.
   - Engine default: [RemoveWordIfNoResults.None]
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/removeWordsIfNoResults/?language=swift)
   */
  public var removeWordsIfNoResults: RemoveWordIfNoResults?

  /**
   Enables the advanced query syntax.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/advancedSyntax/?language=swift)
   */
  public var advancedSyntax: Bool?

  /**
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters//?language=swift)
   */
  public var advancedSyntaxFeatures: [AdvancedSyntaxFeatures]?

  /**
   A list of words that should be considered as optional when found in the query.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/optionalWords/?language=swift)
   */
  public var optionalWords: [String]?

  /**
   Removes stop (task) words from the query before executing it.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/removeStopWords/?language=swift)
   */
  public var removeStopWords: LanguageFeature?

  /**
   List of attributes on which you want to disable the exact ranking criterion.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/disableExactOnAttributes/?language=swift)
   */
  public var disableExactOnAttributes: [Attribute]?

  /**
   Controls how the exact ranking criterion is computed when the query contains only one word.
   - Engine default: .attribute
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/exactOnSingleWordQuery/?language=swift)
   */
  public var exactOnSingleWordQuery: ExactOnSingleWordQuery?

  /**
   List of alternatives that should be considered an exact match by the exact ranking criterion.
   - Engine default: [.ignorePlurals, .singleWordSynonym]
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/alternativesAsExact/?language=swift)
   */
  public var alternativesAsExact: [AlternativesAsExact]?

  /**
   Treats singular, plurals, and other forms of declensions as matching terms.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/ignorePlurals/?language=swift)
   */
  public var ignorePlurals: LanguageFeature?

  /**
   Sets the queryLanguage to be used by language-specific settings and functionalities such as
   [ignorePlurals], [removeStopWords], and
   [CJK word-detection][https://www.algolia.com/doc/guides/textual-relevance/queryLanguage/#using-a-language-specific-dictionary-for-cjk-words].
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/queryLanguages/?language=swift)
   */
  public var queryLanguages: [Language]?

  // MARK: - Query rules

  /**
   Whether rules should be globally enabled.
   - Engine default: true
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/enableRules/?language=swift)
   */
  public var enableRules: Bool?

  /**
   Enables contextual rules.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/ruleContexts/?language=swift)
   */
  public var ruleContexts: [String]?

  // MARK: - Personalization

  /**
   Enable the Personalization feature.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/enablePersonalization/?language=swift)
   */
  public var enablePersonalization: Bool?

  /**
    The `personalizationImpact` parameter sets the percentage of the impact that personalization has on ranking
    records.
    This is set at query time and therefore overrides any impact value you had set on your index.
    The higher the `personalizationImpact`, the more the results are personalized for the user, and the less the
    custom ranking is taken into account in ranking records.
   *
    Usage note:
   *
    - The value must be between 0 and 100 (inclusive).
    - This parameter isn't taken into account if `enablePersonalization` is `false`.
    - Setting `personalizationImpact` to `0` disables the Personalization feature, as if `enablePersonalization`
      were `false`.
   */
  public var personalizationImpact: Int?

  /**
   Associates a certain user token with the current search.
   - Engine default: User ip address
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/userToken/?language=swift)
   */
  public var userToken: UserToken?

  // MARK: - Analytics

  /**
   Whether the current query will be taken into account in the Analytics.
   - Engine default: true
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/analytics/?language=swift)
   */
  public var analytics: Bool?

  /**
   List of tags to apply to the query in the analytics.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/analyticsTags/?language=swift)
   */
  public var analyticsTags: [String]?

  /**
   Whether this query should be taken into consideration by currently active ABTests.
   - Engine default: true
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/enableABTest/?language=swift)
   */
  public var enableABTest: Bool?

  /**
   Enable the Click Analytics feature.
   - Engine default: false.
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/clickAnalytics/?language=swift)
   */
  public var clickAnalytics: Bool?

  // MARK: - Synonyms

  /**
   Whether to take into account an index’s synonyms for a particular search.
   - Engine default: true
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/synonyms/?language=swift)
   */
  public var synonyms: Bool?

  /**
   Whether to highlight and snippet the original word that matches the synonym or the synonym itself.
   - Engine default: true
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/replaceSynonymsInHighlight/?language=swift)
   */
  public var replaceSynonymsInHighlight: Bool?

  /**
   Precision of the proximity ranking criterion.
   - Engine default: 1
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/minProximity/?language=swift)
   */
  public var minProximity: Int?

  /**
   Choose which fields the response will contain. Applies to search and browse queries.
   - Engine default: .all
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/responseFields/?language=swift)
   */
  public var responseFields: [ResponseField]?

  /**
   Whether to include or exclude a query from the processing-time percentile computation.
   - Engine default: true
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/percentileComputation/?language=swift)
   */
  public var percentileComputation: Bool?

  /**
   Custom parameters
   */
  public var customParameters: [String: JSON]?

  public init(_ query: String? = nil) {
    self.query = query
  }

  static let empty = Query()

}

extension Query: Builder {}

extension Query: ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    self.init(value)
  }

}
