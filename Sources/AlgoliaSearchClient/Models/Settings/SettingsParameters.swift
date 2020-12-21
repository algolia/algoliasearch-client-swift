//
//  SettingsParameters.swift
//  
//
//  Created by Vladislav Fitc on 19/11/2020.
//
// swiftlint:disable file_length

import Foundation

public protocol SettingsParameters: CommonParameters {

  // MARK: - Attributes

  /**
   The complete list of attributes that will be used for searching.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/searchableAttributes/?language=swift)
   */
  var searchableAttributes: [SearchableAttribute]? { get set }

  /**
   The complete list of attributes that will be used for faceting.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/attributesForFaceting/?language=swift)
   */
  var attributesForFaceting: [AttributeForFaceting]? { get set }

  /**
   List of attributes that cannot be retrieved at query time.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/unretrievableAttributes/?language=swift)
   */
  var unretrievableAttributes: [Attribute]? { get set }

  // MARK: - Ranking

  /**
   Controls the way results are sorted.
   - Engine default: [.typo, .geo, .words, .filters, .proximity, .attribute, .exact, .custom]
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/ranking/?language=swift)
   */
  var ranking: [RankingCriterion]? { get set }
  
  /**
   Specifies the [CustomRankingCriterion].
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/customRanking/?language=swift)
   */
  var customRanking: [CustomRankingCriterion]? { get set }
  
  /**
   Creates replicas, exact copies of an index.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/replicas/?language=swift)
   */
  var replicas: [IndexName]? { get set }

  // MARK: - Pagination

  /**
   Set the maximum number of hits accessible via pagination.
   - Engine default: 1000
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/paginationlimitedto/?language=swift)
   */
  var paginationLimitedTo: Int? { get set }

  // MARK: - Typos

  /**
   List of words on which you want to disable typo tolerance.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/disableTypoToleranceOnWords/?language=swift)
   */
  var disableTypoToleranceOnWords: [String]? { get set }

  /**
   Control which separators are indexed. Separators are all non-alphanumeric characters except space.
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/separatorsToIndex/?language=swift)
   */
  var separatorsToIndex: String? { get set }

  // MARK: - Languages

  /**
   List of [Attribute] on which to do a decomposition of camel case words.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/camelCaseAttributes/?language=swift)
   */
  var camelCaseAttributes: [Attribute]? { get set }

  /**
   Specify on which [Attribute] in your index Algolia should apply word-splitting (“decompounding”).
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/decompoundedAttributes/?language=swift)
   */
  var decompoundedAttributes: DecompoundedAttributes? { get set }

  /**
   Characters that should not be automatically normalized by the search engine.
   - Engine default: "&quot;&quot;"
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/keepDiacriticsOnCharacters/?language=swift)
   */
  var keepDiacriticsOnCharacters: String? { get set }

  /**
   Override the custom normalization handled by the engine.
   */
  var customNormalization: [String: [String: String]]? { get set }

  /**
   This parameter configures the segmentation of text at indexing time.
   - Accepted value: Language.japanese
   - Input data to index is treated as the given language(s) for segmentation.
   */
  var indexLanguages: [Language]? { get set }

  // MARK: - Query strategy

  /**
   List of [Attribute] on which you want to disable prefix matching.
   - Engine default: []
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/disablePrefixOnAttributes/?language=swift)
   */
  var disablePrefixOnAttributes: [Attribute]? { get set }


  // MARK: - Performance

  /**
   List of [NumericAttributeFilter] that can be used as numerical filters.
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/numericAttributesForFiltering/?language=swift)
   */
  var numericAttributesForFiltering: [NumericAttributeFilter]? { get set }

  /**
   Enables compression of large integer arrays.
   - Engine default: false
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/allowCompressionOfIntegerArray/?language=swift)
   */
  var allowCompressionOfIntegerArray: Bool? { get set }

  // MARK: - Advanced

  /**
   Name of the de-duplication [Attribute] to be used with the [distinct] feature.
   - Engine default: null
   - [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/attributeForDistinct/?language=swift)
   */
  var attributeForDistinct: Attribute? { get set }

  /**
   Lets you store custom data in your indices.
   */
  var userData: JSON? { get set }

  /**
   Settings version.
   */
  var version: Int? { get set }

  /**
   This parameter keeps track of which primary index (if any) a replica is connected to.
   */
  var primary: IndexName? { get set }

}
