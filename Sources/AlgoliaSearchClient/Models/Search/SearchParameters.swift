//
//  SearchParameters.swift
//  
//
//  Created by Vladislav Fitc on 19/11/2020.
//

import Foundation

public protocol SearchParameters {

  // MARK: - Search

  /**
   The text to search in the index.
   - Engine default: ""
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/query/?language=swift)
  */
  var query: String? { get set }

  /**
    Overrides the query parameter and performs a more generic search that can be used to find "similar" results.
    Engine default: ""
    [Documentation][htt ps://www.algolia.com/doc/api-reference/api-parameters/similarQuery/?language=swift)
   */
  var similarQuery: String? { get set }
  
  // MARK: - Attributes

  /**
   Gives control over which attributes to retrieve and which not to retrieve.
   - Engine default: [*]
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/attributesToRetrieve/?language=swift)
   */
  var attributesToRetrieve: [Attribute]? { get set }

  /**
   Restricts a given query to look in only a subset of your searchable attributes.
   - Engine default: all attributes in [Settings.searchableAttributes].
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/restrictSearchableAttributes/?language=swift)
   */
  var restrictSearchableAttributes: [Attribute]? { get set }


  // MARK: - Filtering

  /**
   Filter the query with numeric, facet and/or tag filters.
   - Engine default: ""
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/filters/?language=swift)
   */
  var filters: String? { get set }

  /**
   Filter hits by facet value.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/facetFilters/?language=swift)
   */
  var facetFilters: FiltersStorage? { get set }

  /**
   Create filters for ranking purposes, where records that match the filter are ranked highest.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/optionalFilters/?language=swift)
   */
  var optionalFilters: FiltersStorage? { get set }

  /**
   Filter on numeric attributes.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/numericFilters/?language=swift)
   */
  var numericFilters: FiltersStorage? { get set }

  /**
   Filter hits by tags.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/tagFilters/?language=swift)
   */
  var tagFilters: FiltersStorage? { get set }

  /**
   Determines how to calculate the total score for filtering.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/sumOrFiltersScores/?language=swift)
   */
  var sumOrFiltersScores: Bool? { get set }

  //MARK: - Faceting
  
  /**
   Facets to retrieve.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/facets/?language=swift)
   */
  var facets: Set<Attribute>? { get set }

  /**
   Maximum number of facet values to return for each facet during a regular search.
   - Engine default: 100
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/maxValuesPerFacet/?language=swift)
   */
  var maxValuesPerFacet: Int? { get set }

  /**
   Force faceting to be applied after de-duplication (via the Distinct setting).
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/facetingAfterDistinct/?language=swift)
   */
  var facetingAfterDistinct: Bool? { get set }

  /**
   Controls how facet values are sorted.
   - Engine default: [SortFacetsBy.Count]
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/sortFacetValuesBy/?language=swift)
   */
  var sortFacetsBy: SortFacetsBy? { get set }

  // MARK: - Highlighting-snippeting

  /**
   List of attributes to highlight.
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/attributesToHighlight/?language=swift)
   */
  var attributesToHighlight: [Attribute]? { get set }

  /**
   List of attributes to snippet, with an optional maximum number of words to snippet.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/attributesToSnippet/?language=swift)
   */
  var attributesToSnippet: [Snippet]? { get set }

  /**
   The HTML name to insert before the highlighted parts in all highlight and snippet results.
   - Engine default: <em>
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/highlightPreTag/?language=swift)
   */
  var highlightPreTag: String? { get set }

  /**
   The HTML name to insert after the highlighted parts in all highlight and snippet results.
   - Engine default: </em>
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/highlightPostTag/?language=swift)
   */
  var highlightPostTag: String? { get set }

  /**
   String used as an ellipsis indicator when a snippet is truncated.
   - Engine default: "…" (U+2026, HORIZONTAL ELLIPSIS)
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/snippetEllipsisText/?language=swift)
   */
  var snippetEllipsisText: String? { get set }

  /**
   Restrict highlighting and snippeting to items that matched the query.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/restrictHighlightAndSnippetArrays/?language=swift)
   */
  var restrictHighlightAndSnippetArrays: Bool? { get set }

  // MARK: - Pagination

  /**
   Specify the page to retrieve.
   - Engine default: 0
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/page/?language=swift)
   */
  var page: Int? { get set }

  /**
   Set the number of hits per page.
   - Engine default: 20
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/hitsPerPage/?language=swift)
   */
  var hitsPerPage: Int? { get set }

  /**
   Specify the offset of the first hit to return.
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/offset/?language=swift)
   */
  var offset: Int? { get set }

  /**
   Set the number of hits to retrieve (used only with offset).
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/length/?language=swift)
   */
  var length: Int? { get set }

  // MARK: - Typos

  /**
   Minimum number of characters a word in the query name must contain to accept matches with 1 typo.
   - Engine default: 4
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/minWordSizefor1Typo/?language=swift)
   */
  var minWordSizeFor1Typo: Int? { get set }

  /**
   Minimum number of characters a word in the query name must contain to accept matches with 2 typos.
   - Engine default: 8
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/minWordSizefor2Typos/?language=swift)
   */
  var minWordSizeFor2Typos: Int? { get set }

  /**
   Controls whether typo tolerance is enabled and how it is applied.
   Engine defaults: true
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/typoTolerance/?language=swift)
   */
  var typoTolerance: TypoTolerance? { get set }

  /**
   Whether to allow typos on numbers (“numeric tokens”) in the query name.
   - Engine default: true
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/allowTyposOnNumericTokens/?language=swift)
   */
  var allowTyposOnNumericTokens: Bool? { get set }

  /**
   List of attributes on which you want to disable typo tolerance.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/disableTypoToleranceOnAttributes/?language=swift)
   */
  var disableTypoToleranceOnAttributes: [Attribute]? { get set }

  // MARK: - Geo-Search

  /**
   Search for entries around a central geolocation, enabling a geo search within a circular area.
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/aroundLatLng/?language=swift)
   */
  var aroundLatLng: Point? { get set }

  /**
   Whether to search entries around a given location automatically computed from the requester’s IP address.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/aroundLatLngViaIP/?language=swift)
   */
  var aroundLatLngViaIP: Bool? { get set }

  /**
   Define the maximum radius for a geo search (in meters).
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/aroundRadius/?language=swift)
   */
  var aroundRadius: AroundRadius? { get set }

  /**
   Precision of geo search (in meters), to add grouping by geo location to the ranking formula.
   - Engine default: 1
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/aroundPrecision/?language=swift)
   */
  var aroundPrecision: [AroundPrecision]? { get set }

  /**
   Minimum radius (in meters) used for a geo search when [aroundRadius] is not set.
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/minimumAroundRadius/?language=swift)
   */
  var minimumAroundRadius: Int? { get set }

  /**
   Search inside a rectangular area (in geo coordinates).
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/insideBoundingBox/?language=swift)
   */
  var insideBoundingBox: [BoundingBox]? { get set }

  /**
   Search inside a polygon (in geo coordinates).
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/insidePolygon/?language=swift)
   */
  var insidePolygon: [Polygon]? { get set }
  
  //MARK: - Languages
  
  /**
   Treats singular, plurals, and other forms of declensions as matching terms.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/ignorePlurals/?language=swift)
   */
  var ignorePlurals: LanguageFeature? { get set }

  /**
   Removes stop (task) words from the query before executing it.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/removeStopWords/?language=swift)
   */
  var removeStopWords: LanguageFeature? { get set }

  /**
   Sets the queryLanguage to be used by language-specific settings and functionalities such as
   [ignorePlurals], [removeStopWords], and
   [CJK word-detection][https://www.algolia.com/doc/guides/textual-relevance/queryLanguage/#using-a-language-specific-dictionary-for-cjk-words].
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/queryLanguages/?language=swift)
   */
  var queryLanguages: [Language]? { get set }

  /**
   List of supported languages with their associated language ISO code.
   Provide an easy way to implement voice and natural languages best practices such as ignorePlurals,
   removeStopWords, removeWordsIfNoResults, analyticsTags and ruleContexts.
  */
  var naturalLanguages: [Language]? { get set }
  
  // MARK: - Query rules

  /**
   Whether rules should be globally enabled.
   - Engine default: true
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/enableRules/?language=swift)
   */
  var enableRules: Bool? { get set }

  /**
   Enables contextual rules.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/ruleContexts/?language=swift)
   */
  var ruleContexts: [String]? { get set }

  // MARK: - Personalization

  /**
   Enable the Personalization feature.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/enablePersonalization/?language=swift)
   */
  var enablePersonalization: Bool? { get set }

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
  var personalizationImpact: Int? { get set }

  /**
   Associates a certain user token with the current search.
   - Engine default: User ip address
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/userToken/?language=swift)
   */
  var userToken: UserToken? { get set }

  // MARK: - Query strategy

  /**
   Controls if and how query words are interpreted as [prefixes](https://www.algolia.com/doc/guides/textual-relevance/prefix-search/?language=swift).
   - Engine default: [QueryType.PrefixLast]
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/queryType/?language=swift)
   */
  var queryType: QueryType? { get set }

  /**
   Selects a strategy to remove words from the query when it doesn’t match any hits.
   - Engine default: [RemoveWordIfNoResults.None]
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/removeWordsIfNoResults/?language=swift)
   */
  var removeWordsIfNoResults: RemoveWordIfNoResults? { get set }

  /**
   Enables the advanced query syntax.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/advancedSyntax/?language=swift)
   */
  var advancedSyntax: Bool? { get set }
  
  /**
   A list of words that should be considered as optional when found in the query.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/optionalWords/?language=swift)
   */
  var optionalWords: [String]? { get set }

  /**
   List of attributes on which you want to disable the exact ranking criterion.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/disableExactOnAttributes/?language=swift)
   */
  var disableExactOnAttributes: [Attribute]? { get set }

  /**
   Controls how the exact ranking criterion is computed when the query contains only one word.
   - Engine default: .attribute
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/exactOnSingleWordQuery/?language=swift)
   */
  var exactOnSingleWordQuery: ExactOnSingleWordQuery? { get set }

  /**
   List of alternatives that should be considered an exact match by the exact ranking criterion.
   - Engine default: [.ignorePlurals, .singleWordSynonym]
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/alternativesAsExact/?language=swift)
   */
  var alternativesAsExact: [AlternativesAsExact]? { get set }

  /**
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters//?language=swift)
   */
  var advancedSyntaxFeatures: [AdvancedSyntaxFeatures]? { get set }

  // MARK: - Advanced

  /**
   Enables de-duplication or grouping of results.
   - Engine default: 0
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/distinct/?language=swift)
   */
  var distinct: Distinct? { get set }

  /**
   Retrieve detailed ranking information.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/getRankingInfo/?language=swift)
   */
  var getRankingInfo: Bool? { get set }
  
  /**
   Enable the Click Analytics feature.
   - Engine default: false.
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/clickAnalytics/?language=swift)
   */
  var clickAnalytics: Bool? { get set }

  /**
   Whether the current query will be taken into account in the Analytics.
   - Engine default: true
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/analytics/?language=swift)
   */
  var analytics: Bool? { get set }

  /**
   List of tags to apply to the query in the analytics.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/analyticsTags/?language=swift)
   */
  var analyticsTags: [String]? { get set }
  
  /**
   Whether to take into account an index’s synonyms for a particular search.
   - Engine default: true
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/synonyms/?language=swift)
   */
  var synonyms: Bool? { get set }

  /**
   Whether to highlight and snippet the original word that matches the synonym or the synonym itself.
   - Engine default: true
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/replaceSynonymsInHighlight/?language=swift)
   */
  var replaceSynonymsInHighlight: Bool? { get set }

  /**
   Precision of the proximity ranking criterion.
   - Engine default: 1
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/minProximity/?language=swift)
   */
  var minProximity: Int? { get set }

  /**
   Choose which fields the response will contain. Applies to search and browse queries.
   - Engine default: .all
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/responseFields/?language=swift)
   */
  var responseFields: [ResponseField]? { get set }
  
  /**
   Maximum number of facet hits to return during a search for facet values.
   - Engine default: 10
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/maxFacetHits/?language=swift)
   */
  var maxFacetHits: Int? { get set }
  
  /**
   Whether to include or exclude a query from the processing-time percentile computation.
   - Engine default: true
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/percentileComputation/?language=swift)
   */
  var percentileComputation: Bool? { get set }
  
  /**
   When attribute is ranked above proximity in your ranking formula, proximity is used to select
   which searchable attribute is matched in the attribute ranking stage.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/attributeCriteriaComputedByMinProximity/?language=swift)
   */
  var attributeCriteriaComputedByMinProximity: Bool? { get set }

  /**
   Whether this query should be taken into consideration by currently active ABTests.
   - Engine default: true
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/enableABTest/?language=swift)
   */
  var enableABTest: Bool? { get set }

  /**
   Enriches the API’s response with meta-information as to how the query was processed.
   It is possible to enable several ExplainModule independently.
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/_/?language=swift)
   */
  var explainModules: [ExplainModule]? { get set }

}
