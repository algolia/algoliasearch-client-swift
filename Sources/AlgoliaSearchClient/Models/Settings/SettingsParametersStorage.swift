//
//  SettingsParametersStorage.swift
//  
//
//  Created by Vladislav Fitc on 20/11/2020.
//

import Foundation

struct SettingsParametersStorage: SettingsParameters {
  var searchableAttributes: [SearchableAttribute]?
  var attributesForFaceting: [AttributeForFaceting]?
  var unretrievableAttributes: [Attribute]?
  var attributesToRetrieve: [Attribute]?
  var ranking: [RankingCriterion]?
  var customRanking: [CustomRankingCriterion]?
  var replicas: [IndexName]?
  var maxValuesPerFacet: Int?
  var sortFacetsBy: SortFacetsBy?
  var attributesToHighlight: [Attribute]?
  var attributesToSnippet: [Snippet]?
  var highlightPreTag: String?
  var highlightPostTag: String?
  var snippetEllipsisText: String?
  var restrictHighlightAndSnippetArrays: Bool?
  var hitsPerPage: Int?
  var paginationLimitedTo: Int?
  var minWordSizeFor1Typo: Int?
  var minWordSizeFor2Typos: Int?
  var typoTolerance: TypoTolerance?
  var allowTyposOnNumericTokens: Bool?
  var disableTypoToleranceOnAttributes: [Attribute]?
  var disableTypoToleranceOnWords: [String]?
  var separatorsToIndex: String?
  var ignorePlurals: LanguageFeature?
  var removeStopWords: LanguageFeature?
  var camelCaseAttributes: [Attribute]?
  var decompoundedAttributes: DecompoundedAttributes?
  var keepDiacriticsOnCharacters: String?
  var customNormalization: [String: [String: String]]?
  var queryLanguages: [Language]?
  var indexLanguages: [Language]?
  var enableRules: Bool?
  var enablePersonalization: Bool?
  var queryType: QueryType?
  var removeWordsIfNoResults: RemoveWordIfNoResults?
  var advancedSyntax: Bool?
  var optionalWords: [String]?
  var disablePrefixOnAttributes: [Attribute]?
  var disableExactOnAttributes: [Attribute]?
  var exactOnSingleWordQuery: ExactOnSingleWordQuery?
  var alternativesAsExact: [AlternativesAsExact]?
  var advancedSyntaxFeatures: [AdvancedSyntaxFeatures]?
  var numericAttributesForFiltering: [NumericAttributeFilter]?
  var allowCompressionOfIntegerArray: Bool?
  var attributeForDistinct: Attribute?
  var distinct: Distinct?
  var replaceSynonymsInHighlight: Bool?
  var minProximity: Int?
  var responseFields: [ResponseField]?
  var maxFacetHits: Int?
  var attributeCriteriaComputedByMinProximity: Bool?
  var userData: JSON?
  var version: Int?
  var primary: IndexName?
}

extension SettingsParametersStorage: Codable {
  typealias CodingKeys = SettingsParametersCodingKeys
}

protocol SettingsParametersStorageContainer: SettingsParameters {
  var settingsParametersStorage: SettingsParametersStorage { get set }
}

extension SettingsParametersStorageContainer {

  public var searchableAttributes: [SearchableAttribute]? {
    get { settingsParametersStorage.searchableAttributes }
    set { settingsParametersStorage.searchableAttributes = newValue }
  }
  public var attributesForFaceting: [AttributeForFaceting]? {
    get { settingsParametersStorage.attributesForFaceting }
    set { settingsParametersStorage.attributesForFaceting = newValue }
  }
  public var unretrievableAttributes: [Attribute]? {
    get { settingsParametersStorage.unretrievableAttributes }
    set { settingsParametersStorage.unretrievableAttributes = newValue }
  }
  public var attributesToRetrieve: [Attribute]? {
    get { settingsParametersStorage.attributesToRetrieve }
    set { settingsParametersStorage.attributesToRetrieve = newValue }
  }
  public var ranking: [RankingCriterion]? {
    get { settingsParametersStorage.ranking }
    set { settingsParametersStorage.ranking = newValue }
  }
  public var customRanking: [CustomRankingCriterion]? {
    get { settingsParametersStorage.customRanking }
    set { settingsParametersStorage.customRanking = newValue }
  }
  public var replicas: [IndexName]? {
    get { settingsParametersStorage.replicas }
    set { settingsParametersStorage.replicas = newValue }
  }
  public var maxValuesPerFacet: Int? {
    get { settingsParametersStorage.maxValuesPerFacet }
    set { settingsParametersStorage.maxValuesPerFacet = newValue }
  }
  public var sortFacetsBy: SortFacetsBy? {
    get { settingsParametersStorage.sortFacetsBy }
    set { settingsParametersStorage.sortFacetsBy = newValue }
  }
  public var attributesToHighlight: [Attribute]? {
    get { settingsParametersStorage.attributesToHighlight }
    set { settingsParametersStorage.attributesToHighlight = newValue }
  }
  public var attributesToSnippet: [Snippet]? {
    get { settingsParametersStorage.attributesToSnippet }
    set { settingsParametersStorage.attributesToSnippet = newValue }
  }
  public var highlightPreTag: String? {
    get { settingsParametersStorage.highlightPreTag }
    set { settingsParametersStorage.highlightPreTag = newValue }
  }
  public var highlightPostTag: String? {
    get { settingsParametersStorage.highlightPostTag }
    set { settingsParametersStorage.highlightPostTag = newValue }
  }
  public var snippetEllipsisText: String? {
    get { settingsParametersStorage.snippetEllipsisText }
    set { settingsParametersStorage.snippetEllipsisText = newValue }
  }
  public var restrictHighlightAndSnippetArrays: Bool? {
    get { settingsParametersStorage.restrictHighlightAndSnippetArrays }
    set { settingsParametersStorage.restrictHighlightAndSnippetArrays = newValue }
  }
  public var hitsPerPage: Int? {
    get { settingsParametersStorage.hitsPerPage }
    set { settingsParametersStorage.hitsPerPage = newValue }
  }
  public var paginationLimitedTo: Int? {
    get { settingsParametersStorage.paginationLimitedTo }
    set { settingsParametersStorage.paginationLimitedTo = newValue }
  }
  public var minWordSizeFor1Typo: Int? {
    get { settingsParametersStorage.minWordSizeFor1Typo }
    set { settingsParametersStorage.minWordSizeFor1Typo = newValue }
  }
  public var minWordSizeFor2Typos: Int? {
    get { settingsParametersStorage.minWordSizeFor2Typos }
    set { settingsParametersStorage.minWordSizeFor2Typos = newValue }
  }
  public var typoTolerance: TypoTolerance? {
    get { settingsParametersStorage.typoTolerance }
    set { settingsParametersStorage.typoTolerance = newValue }
  }
  public var allowTyposOnNumericTokens: Bool? {
    get { settingsParametersStorage.allowTyposOnNumericTokens }
    set { settingsParametersStorage.allowTyposOnNumericTokens = newValue }
  }
  public var disableTypoToleranceOnAttributes: [Attribute]? {
    get { settingsParametersStorage.disableTypoToleranceOnAttributes }
    set { settingsParametersStorage.disableTypoToleranceOnAttributes = newValue }
  }
  public var disableTypoToleranceOnWords: [String]? {
    get { settingsParametersStorage.disableTypoToleranceOnWords }
    set { settingsParametersStorage.disableTypoToleranceOnWords = newValue }
  }
  public var separatorsToIndex: String? {
    get { settingsParametersStorage.separatorsToIndex }
    set { settingsParametersStorage.separatorsToIndex = newValue }
  }
  public var ignorePlurals: LanguageFeature? {
    get { settingsParametersStorage.ignorePlurals }
    set { settingsParametersStorage.ignorePlurals = newValue }
  }
  public var removeStopWords: LanguageFeature? {
    get { settingsParametersStorage.removeStopWords }
    set { settingsParametersStorage.removeStopWords = newValue }
  }
  public var camelCaseAttributes: [Attribute]? {
    get { settingsParametersStorage.camelCaseAttributes }
    set { settingsParametersStorage.camelCaseAttributes = newValue }
  }
  public var decompoundedAttributes: DecompoundedAttributes? {
    get { settingsParametersStorage.decompoundedAttributes }
    set { settingsParametersStorage.decompoundedAttributes = newValue }
  }
  public var keepDiacriticsOnCharacters: String? {
    get { settingsParametersStorage.keepDiacriticsOnCharacters }
    set { settingsParametersStorage.keepDiacriticsOnCharacters = newValue }
  }
  public var customNormalization: [String: [String: String]]? {
    get { settingsParametersStorage.customNormalization }
    set { settingsParametersStorage.customNormalization = newValue }
  }
  public var queryLanguages: [Language]? {
    get { settingsParametersStorage.queryLanguages }
    set { settingsParametersStorage.queryLanguages = newValue }
  }
  public var indexLanguages: [Language]? {
    get { settingsParametersStorage.indexLanguages }
    set { settingsParametersStorage.indexLanguages = newValue }
  }
  public var enableRules: Bool? {
    get { settingsParametersStorage.enableRules }
    set { settingsParametersStorage.enableRules = newValue }
  }
  public var enablePersonalization: Bool? {
    get { settingsParametersStorage.enablePersonalization }
    set { settingsParametersStorage.enablePersonalization = newValue }
  }
  public var queryType: QueryType? {
    get { settingsParametersStorage.queryType }
    set { settingsParametersStorage.queryType = newValue }
  }
  public var removeWordsIfNoResults: RemoveWordIfNoResults? {
    get { settingsParametersStorage.removeWordsIfNoResults }
    set { settingsParametersStorage.removeWordsIfNoResults = newValue }
  }
  public var advancedSyntax: Bool? {
    get { settingsParametersStorage.advancedSyntax }
    set { settingsParametersStorage.advancedSyntax = newValue }
  }
  public var optionalWords: [String]? {
    get { settingsParametersStorage.optionalWords }
    set { settingsParametersStorage.optionalWords = newValue }
  }
  public var disablePrefixOnAttributes: [Attribute]? {
    get { settingsParametersStorage.disablePrefixOnAttributes }
    set { settingsParametersStorage.disablePrefixOnAttributes = newValue }
  }
  public var disableExactOnAttributes: [Attribute]? {
    get { settingsParametersStorage.disableExactOnAttributes }
    set { settingsParametersStorage.disableExactOnAttributes = newValue }
  }
  public var exactOnSingleWordQuery: ExactOnSingleWordQuery? {
    get { settingsParametersStorage.exactOnSingleWordQuery }
    set { settingsParametersStorage.exactOnSingleWordQuery = newValue }
  }
  public var alternativesAsExact: [AlternativesAsExact]? {
    get { settingsParametersStorage.alternativesAsExact }
    set { settingsParametersStorage.alternativesAsExact = newValue }
  }
  public var advancedSyntaxFeatures: [AdvancedSyntaxFeatures]? {
    get { settingsParametersStorage.advancedSyntaxFeatures }
    set { settingsParametersStorage.advancedSyntaxFeatures = newValue }
  }
  public var numericAttributesForFiltering: [NumericAttributeFilter]? {
    get { settingsParametersStorage.numericAttributesForFiltering }
    set { settingsParametersStorage.numericAttributesForFiltering = newValue }
  }
  public var allowCompressionOfIntegerArray: Bool? {
    get { settingsParametersStorage.allowCompressionOfIntegerArray }
    set { settingsParametersStorage.allowCompressionOfIntegerArray = newValue }
  }
  public var attributeForDistinct: Attribute? {
    get { settingsParametersStorage.attributeForDistinct }
    set { settingsParametersStorage.attributeForDistinct = newValue }
  }
  public var distinct: Distinct? {
    get { settingsParametersStorage.distinct }
    set { settingsParametersStorage.distinct = newValue }
  }
  public var replaceSynonymsInHighlight: Bool? {
    get { settingsParametersStorage.replaceSynonymsInHighlight }
    set { settingsParametersStorage.replaceSynonymsInHighlight = newValue }
  }
  public var minProximity: Int? {
    get { settingsParametersStorage.minProximity }
    set { settingsParametersStorage.minProximity = newValue }
  }
  public var responseFields: [ResponseField]? {
    get { settingsParametersStorage.responseFields }
    set { settingsParametersStorage.responseFields = newValue }
  }
  public var maxFacetHits: Int? {
    get { settingsParametersStorage.maxFacetHits }
    set { settingsParametersStorage.maxFacetHits = newValue }
  }
  public var attributeCriteriaComputedByMinProximity: Bool? {
    get { settingsParametersStorage.attributeCriteriaComputedByMinProximity }
    set { settingsParametersStorage.attributeCriteriaComputedByMinProximity = newValue }
  }
  public var userData: JSON? {
    get { settingsParametersStorage.userData }
    set { settingsParametersStorage.userData = newValue }
  }
  public var version: Int? {
    get { settingsParametersStorage.version }
    set { settingsParametersStorage.version = newValue }
  }
  public var primary: IndexName? {
    get { settingsParametersStorage.primary }
    set { settingsParametersStorage.primary = newValue }
  }

}
