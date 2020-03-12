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
  var searchableAttributes: [SearchableAttribute]? = nil
  
  /**
   The complete list of attributes that will be used for faceting.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/attributesForFaceting/?language=swift)
   */
  var attributesForFaceting: [AttributeForFaceting]? = nil
  
  /**
   List of attributes that cannot be retrieved at query time.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/unretrievableAttributes/?language=swift)
   */
  var unretrievableAttributes: [Attribute]? = nil
  
  /**
   - Gives control over which attributes to retrieve and which not to retrieve.
   - Engine default: [*]
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/attributesToRetrieve/?language=swift)
   */
  var attributesToRetrieve: [Attribute]? = nil
  
  /**
   Controls the way results are sorted.
   - Engine default: [.typo, .geo, .words, .filters, .proximity, .attribute, .exact, .custom]
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/ranking/?language=swift)
   */
  
  var ranking: [RankingCriterion]? = nil
  /**
   Specifies the [CustomRankingCriterion].
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/customRanking/?language=swift)
   */
  
  var customRanking: [CustomRankingCriterion]? = nil
  /**
   Creates replicas, exact copies of an index.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/replicas/?language=swift)
   */
  
  var replicas: [IndexName]? = nil
  /**
   Engine default: 100
   - Maximum number of facet values to return for each facet during a regular search.
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/maxValuesPerFacet/?language=swift)
   */
  var maxValuesPerFacet: Int? = nil
  
  /**
   Controls how facet values are sorted.
   - Engine default: .count
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/sortFacetValuesBy/?language=swift)
   */
  var sortFacetsBy: SortFacetsBy? = nil
  
  /**
   List of attributes to highlight.
   - Engine default: [*]
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/attributesToHighlight/?language=swift)
   */
  var attributesToHighlight: [Attribute]? = nil
  
  /**
   List of attributes to snippet.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/attributesToSnippet/?language=swift)
   */
  var attributesToSnippet: [Snippet]? = nil
  
  /**
   The HTML string to insert before the highlighted parts in all highlight and snippet results.
   - Needs to be used along [highlightPostTag].
   - Engine default: "<em>"
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/highlightPreTag/?language=swift)
   */
  var highlightPreTag: String? = nil
  
  /**
   The HTML string to insert after the highlighted parts in all highlight and snippet results.
   - Needs to be used along [highlightPreTag].
   - Engine default: "</em>"
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/highlightPostTag/?language=swift)
   */
  var highlightPostTag: String? = nil
  
  /**
   String used as an ellipsis indicator when a snippet is truncated.
   - Engine default: "…" (U+2026, HORIZONTAL ELLIPSIS)
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/snippetEllipsisText/?language=swift)
   */
  var snippetEllipsisText: String? = nil
  
  /**
   Restrict highlighting and snippeting to items that matched the query.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/restrictHighlightAndSnippetArrays/?language=swift)
   */
  var restrictHighlightAndSnippetArrays: Bool? = nil
  
  /**
   Set the number of hits per page.
   - Engine default: 20
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/hitsPerPage/?language=swift)
   */
  var hitsPerPage: Int? = nil
  
  /**
   Set the maximum number of hits accessible via pagination.
   - Engine default: 1000
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/paginationlimitedto/?language=swift)
   */
  var paginationLimitedTo: Int? = nil
  
  /**
   Minimum number of characters a word in the query name must contain to accept matches with 1 typo.
   - Engine default: 4
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/minWordSizefor1Typo/?language=swift)
   */
  var minWordSizeFor1Typo: Int? = nil
  
  /**
   Minimum number of characters a word in the query name must contain to accept matches with 2 typos.
   - Engine default: 8
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/minWordSizefor2Typos/?language=swift)
   */
  var minWordSizeFor2Typos: Int? = nil
  
  /**
   Controls whether typo tolerance is enabled and how it is applied.
   - Engine defaults: true
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/typoTolerance/?language=swift)
   */
  var typoTolerance: TypoTolerance? = nil
  
  /**
   Whether to allow typos on numbers (“numeric tokens”) in the query name.
   - Engine default: true
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/allowTyposOnNumericTokens/?language=swift)
   */
  var allowTyposOnNumericTokens: Bool? = nil
  
  /**
   List of attributes on which you want to disable typo tolerance.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/disabletypotoleranceonattributes/?language=swift)
   */
  var disableTypoToleranceOnAttributes: [Attribute]? = nil
  
  /**
   List of words on which you want to disable typo tolerance.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/disableTypoToleranceOnWords/?language=swift)
   */
  var disableTypoToleranceOnWords: [String]? = nil
  
  /**
   Control which separators are indexed. Separators are all non-alphanumeric characters except space.
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/separatorsToIndex/?language=swift)
   */
  var separatorsToIndex: String? = nil
  
  /**
   Treats singular, plurals, and other forms of declensions as matching terms.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/ignorePlurals/?language=swift)
   */
  var ignorePlurals: IgnorePlurals? = nil
  
  /**
   Removes stop (task) words from the query before executing it.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/removeStopWords/?language=swift)
   */
  var removeStopWords: RemoveStopWords? = nil
  
  /**
   List of [Attribute] on which to do a decomposition of camel case words.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/camelCaseAttributes/?language=swift)
   */
  var camelCaseAttributes: [Attribute]? = nil
  
  /**
   Specify on which [Attribute] in your index Algolia should apply word-splitting (“decompounding”).
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/decompoundedAttributes/?language=swift)
   */
  var decompoundedAttributes: DecompoundedAttributes? = nil
  
  /**
   Characters that should not be automatically normalized by the search engine.
   - Engine default: "&quot;&quot;"
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/keepDiacriticsOnCharacters/?language=swift)
   */
  var keepDiacriticsOnCharacters: String? = nil
  
  /**
   Sets the languages to be used by language-specific settings and functionalities such as [ignorePlurals],
   - [removeStopWords and CJK word-detection](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/handling-natural-languages-nlp/in-depth/normalization/#using-a-language-specific-dictionary-for-cjk-words).
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/queryLanguages/?language=swift)
   */
  var queryLanguages: [Language]? = nil
  
  /**
   Whether rules should be globally enabled.
   - Engine default: true
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/enableRules/?language=swift)
   */
  var enableRules: Bool? = nil
  
  /**
   Controls if and how query words are interpreted as [prefixes][https://www.algolia.com/doc/guides/textual-relevance/prefix-search/?language=swift).
   - Engine default: .prefixLast
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/queryType/?language=swift)
   */
  var queryType: QueryType? = nil
  
  /**
   Selects a strategy to remove words from the query when it doesn’t match any hits.
   - Engine default: .none
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/removeWordsIfNoResults/?language=swift)
   */
  var removeWordsIfNoResults: RemoveWordIfNoResults? = nil
  
  /**
   Enables the advanced query syntax.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/advancedSyntax/?language=swift)
   */
  var advancedSyntax: Bool? = nil
  
  /**
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters//?language=swift)
   */
  var advancedSyntaxFeatures: [AdvancedSyntaxFeatures]? = nil
  
  /**
   A list of words that should be considered as optional when found in the query.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/optionalWords/?language=swift)
   */
  var optionalWords: [String]? = nil
  
  /**
   List of [Attribute] on which you want to disable prefix matching.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/disablePrefixOnAttributes/?language=swift)
   */
  var disablePrefixOnAttributes: [Attribute]? = nil
  
  /**
   List of [Attribute] on which you want to disable the exact ranking criterion.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/disableExactOnAttributes/?language=swift)
   */
  var disableExactOnAttributes: [Attribute]? = nil
  
  /**
   Controls how the exact ranking criterion is computed when the query contains only one word.
   - Engine default: .attribute
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/exactOnSingleWordQuery/?language=swift)
   */
  var exactOnSingleWordQuery: ExactOnSingleWordQuery? = nil
  
  /**
   List of alternatives that should be considered an exact match by the exact ranking criterion.
   - Engine default: [.ignorePlurals, .singleWordSynonym]
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/alternativesAsExact/?language=swift)
   */
  var alternativesAsExact: [AlternativesAsExact]? = nil
  
  /**
   List of [NumericAttributeFilter] that can be used as numerical filters.
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/numericAttributesForFiltering/?language=swift)
   */
  var numericAttributesForFiltering: [NumericAttributeFilter]? = nil
  
  /**
   Enables compression of large integer arrays.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/allowCompressionOfIntegerArray/?language=swift)
   */
  var allowCompressionOfIntegerArray: Bool? = nil
  
  /**
   Name of the de-duplication [Attribute] to be used with the [distinct] feature.
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/attributeForDistinct/?language=swift)
   */
  var attributeForDistinct: Attribute? = nil
  
  /**
   Enables de-duplication or grouping of results.
   - Engine default: 0
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/distinct/?language=swift)
   */
  var distinct: Distinct? = nil
  
  /**
   Whether to highlight and snippet the original word that matches the synonym or the synonym itself.
   - Engine default: true
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters//?language=swift)
   */
  var replaceSynonymsInHighlight: Bool? = nil
  
  /**
   Precision of the proximity ranking criterion.
   - Engine default: 1
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/minProximity/?language=swift)
   */
  var minProximity: Int? = nil
  
  /**
   Choose which fields the response will contain. Applies to search and browse queries.
   - Engine default: .all
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/responseFields/?language=swift)
   */
  var responseFields: [ResponseField]? = nil
  
  /**
   Maximum number of facet hits to return during a search for facet values.
   - Engine default: 10
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/maxFacetHits/?language=swift)
   */
  var maxFacetHits: Int? = nil
  /**
   Settings version.
   */
  var version: Int? = nil
  
  /**
   Lets you store custom data in your indices.
   */
  var userData: JSON? = nil
  
  /**
   This parameter configures the segmentation of text at indexing time.
   - Accepted value: Language.japanese
   - Input data to index is treated as the given language(s) for segmentation.
   */
  var indexLanguages: [Language]? = nil
  
  /**
   Override the custom normalization handled by the engine.
   */
  var customNormalization: [String: [String: String]]? = nil
  
  /**
   This parameter keeps track of which primary index (if any) a replica is connected to.
   */
  var primary: IndexName? = nil
  
}

public extension Settings {
  
  enum CodingKeys: String, CodingKey {
    case sortFacetsBy = "sortFacetValuesBy"
  }
  
}

public extension Settings {
  
  enum Key: String, Codable {
    case testKey
  }
  
}
