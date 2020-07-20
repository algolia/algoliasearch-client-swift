//
//  Settings+Codable.swift
//  AlgoliaSearchClient
//
//  Created by Vladislav Fitc on 24/03/2020.
//

import Foundation

extension Settings {

  public typealias Key = CodingKeys

  public enum CodingKeys: String, CodingKey {
    case searchableAttributes
    case attributesForFaceting
    case unretrievableAttributes
    case attributesToRetrieve
    case ranking
    case customRanking
    case replicas
    case maxValuesPerFacet
    case sortFacetsBy = "sortFacetValuesBy"
    case attributesToHighlight
    case attributesToSnippet
    case highlightPreTag
    case highlightPostTag
    case snippetEllipsisText
    case restrictHighlightAndSnippetArrays
    case hitsPerPage
    case paginationLimitedTo
    case minWordSizeFor1Typo = "minWordSizefor1Typo"
    case minWordSizeFor2Typos = "minWordSizefor2Typos"
    case typoTolerance
    case allowTyposOnNumericTokens
    case disableTypoToleranceOnAttributes
    case disableTypoToleranceOnWords
    case separatorsToIndex
    case ignorePlurals
    case removeStopWords
    case camelCaseAttributes
    case decompoundedAttributes
    case keepDiacriticsOnCharacters
    case queryLanguages
    case enableRules
    case enablePersonalization
    case queryType
    case removeWordsIfNoResults
    case advancedSyntax
    case advancedSyntaxFeatures
    case optionalWords
    case disablePrefixOnAttributes
    case disableExactOnAttributes
    case exactOnSingleWordQuery
    case alternativesAsExact
    case numericAttributesForFiltering
    case allowCompressionOfIntegerArray
    case attributeForDistinct
    case distinct
    case replaceSynonymsInHighlight
    case minProximity
    case responseFields
    case maxFacetHits
    case userData
    case indexLanguages
    case customNormalization
    case primary
    case attributeCriteriaComputedByMinProximity
  }

}
