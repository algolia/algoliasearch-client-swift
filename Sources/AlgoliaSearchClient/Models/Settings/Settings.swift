//
//  Settings.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation

public struct Settings: Codable {

  /**
   The complete list of attributes that will be used for searching.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/searchableAttributes/?language=swift)
   */
  public var searchableAttributes: [SearchableAttribute]?

  /**
   The complete list of attributes that will be used for faceting.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/attributesForFaceting/?language=swift)
   */
  public var attributesForFaceting: [AttributeForFaceting]?

  /**
   List of attributes that cannot be retrieved at query time.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/unretrievableAttributes/?language=swift)
   */
  public var unretrievableAttributes: [Attribute]?

  /**
   - Gives control over which attributes to retrieve and which not to retrieve.
   - Engine default: [*]
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/attributesToRetrieve/?language=swift)
   */
  public var attributesToRetrieve: [Attribute]?

  /**
   Controls the way results are sorted.
   - Engine default: [.typo, .geo, .words, .filters, .proximity, .attribute, .exact, .custom]
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/ranking/?language=swift)
   */

  public var ranking: [RankingCriterion]?
  /**
   Specifies the [CustomRankingCriterion].
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/customRanking/?language=swift)
   */

  public var customRanking: [CustomRankingCriterion]?
  /**
   Creates replicas, exact copies of an index.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/replicas/?language=swift)
   */

  public var replicas: [IndexName]?
  /**
   Engine default: 100
   - Maximum number of facet values to return for each facet during a regular search.
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/maxValuesPerFacet/?language=swift)
   */
  public var maxValuesPerFacet: Int?

  /**
   Controls how facet values are sorted.
   - Engine default: .count
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/sortFacetValuesBy/?language=swift)
   */
  public var sortFacetsBy: SortFacetsBy?

  /**
   List of attributes to highlight.
   - Engine default: [*]
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/attributesToHighlight/?language=swift)
   */
  public var attributesToHighlight: [Attribute]?

  /**
   List of attributes to snippet.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/attributesToSnippet/?language=swift)
   */
  public var attributesToSnippet: [Snippet]?

  /**
   The HTML string to insert before the highlighted parts in all highlight and snippet results.
   - Needs to be used along [highlightPostTag].
   - Engine default: "<em>"
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/highlightPreTag/?language=swift)
   */
  public var highlightPreTag: String?

  /**
   The HTML string to insert after the highlighted parts in all highlight and snippet results.
   - Needs to be used along [highlightPreTag].
   - Engine default: "</em>"
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

  /**
   Set the number of hits per page.
   - Engine default: 20
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/hitsPerPage/?language=swift)
   */
  public var hitsPerPage: Int?

  /**
   Set the maximum number of hits accessible via pagination.
   - Engine default: 1000
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/paginationlimitedto/?language=swift)
   */
  public var paginationLimitedTo: Int?

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
   - Engine defaults: true
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
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/disabletypotoleranceonattributes/?language=swift)
   */
  public var disableTypoToleranceOnAttributes: [Attribute]?

  /**
   List of words on which you want to disable typo tolerance.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/disableTypoToleranceOnWords/?language=swift)
   */
  public var disableTypoToleranceOnWords: [String]?

  /**
   Control which separators are indexed. Separators are all non-alphanumeric characters except space.
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/separatorsToIndex/?language=swift)
   */
  public var separatorsToIndex: String?

  /**
   Treats singular, plurals, and other forms of declensions as matching terms.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/ignorePlurals/?language=swift)
   */
  public var ignorePlurals: LanguageFeature?

  /**
   Removes stop (task) words from the query before executing it.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/removeStopWords/?language=swift)
   */
  public var removeStopWords: LanguageFeature?

  /**
   List of [Attribute] on which to do a decomposition of camel case words.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/camelCaseAttributes/?language=swift)
   */
  public var camelCaseAttributes: [Attribute]?

  /**
   Specify on which [Attribute] in your index Algolia should apply word-splitting (“decompounding”).
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/decompoundedAttributes/?language=swift)
   */
  public var decompoundedAttributes: DecompoundedAttributes?

  /**
   Characters that should not be automatically normalized by the search engine.
   - Engine default: "&quot;&quot;"
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/keepDiacriticsOnCharacters/?language=swift)
   */
  public var keepDiacriticsOnCharacters: String?

  /**
   Sets the languages to be used by language-specific settings and functionalities such as [ignorePlurals],
   - [removeStopWords and CJK word-detection](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/handling-natural-languages-nlp/in-depth/normalization/#using-a-language-specific-dictionary-for-cjk-words).
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/queryLanguages/?language=swift)
   */
  public var queryLanguages: [Language]?

  /**
   Whether rules should be globally enabled.
   - Engine default: true
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/enableRules/?language=swift)
   */
  public var enableRules: Bool?
  
  /**
   Enable the Personalization feature.
   - Engine default: false
   - [Documentation][https://www.algolia.com/doc/api-reference/api-parameters/enablePersonalization/?language=swift]
   */
  public var enablePersonalization: Bool?

  /**
   Controls if and how query words are interpreted as [prefixes][https://www.algolia.com/doc/guides/textual-relevance/prefix-search/?language=swift).
   - Engine default: .prefixLast
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/queryType/?language=swift)
   */
  public var queryType: QueryType?

  /**
   Selects a strategy to remove words from the query when it doesn’t match any hits.
   - Engine default: .none
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
   List of [Attribute] on which you want to disable prefix matching.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/disablePrefixOnAttributes/?language=swift)
   */
  public var disablePrefixOnAttributes: [Attribute]?

  /**
   List of [Attribute] on which you want to disable the exact ranking criterion.
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
   List of [NumericAttributeFilter] that can be used as numerical filters.
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/numericAttributesForFiltering/?language=swift)
   */
  public var numericAttributesForFiltering: [NumericAttributeFilter]?

  /**
   Enables compression of large integer arrays.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/allowCompressionOfIntegerArray/?language=swift)
   */
  public var allowCompressionOfIntegerArray: Bool?

  /**
   Name of the de-duplication [Attribute] to be used with the [distinct] feature.
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/attributeForDistinct/?language=swift)
   */
  public var attributeForDistinct: Attribute?

  /**
   Enables de-duplication or grouping of results.
   - Engine default: 0
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/distinct/?language=swift)
   */
  public var distinct: Distinct?

  /**
   Whether to highlight and snippet the original word that matches the synonym or the synonym itself.
   - Engine default: true
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters//?language=swift)
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
   Maximum number of facet hits to return during a search for facet values.
   - Engine default: 10
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/maxFacetHits/?language=swift)
   */
  public var maxFacetHits: Int?

  /**
   When attribute is ranked above proximity in your ranking formula, proximity is used to select
   which searchable attribute is matched in the attribute ranking stage.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/attributeCriteriaComputedByMinProximity/?language=swift)
   */
  public var attributeCriteriaComputedByMinProximity: Bool?

  /**
   Settings version.
   */
  public var version: Int?

  /**
   Lets you store custom data in your indices.
   */
  public var userData: JSON?

  /**
   This parameter configures the segmentation of text at indexing time.
   - Accepted value: Language.japanese
   - Input data to index is treated as the given language(s) for segmentation.
   */
  public var indexLanguages: [Language]?

  /**
   Override the custom normalization handled by the engine.
   */
  public var customNormalization: [String: [String: String]]?

  /**
   This parameter keeps track of which primary index (if any) a replica is connected to.
   */
  public var primary: IndexName?

  public init() {
  }

}

extension Settings: Builder {}
