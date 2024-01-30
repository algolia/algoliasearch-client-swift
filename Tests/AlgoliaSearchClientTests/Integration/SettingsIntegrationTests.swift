//
//  SettingsIntegrationTests.swift
//
//
//  Created by Vladislav Fitc on 05/03/2020.
//

import Foundation
import XCTest

@testable import AlgoliaSearchClient

class SettingsIntegrationTests: IntegrationTestCase {
  override var indexNameSuffix: String? {
    "settings"
  }

  override var retryableTests: [() throws -> Void] {
    [settings]
  }

  func settings() throws {
    let indexInitialization = try index.saveObject(TestRecord(), autoGeneratingObjectID: true)
    try indexInitialization.wait()

    let settings = Settings()
      .set(
        \.searchableAttributes,
        to: [
          "attribute1", "attribute2", "attribute3", .unordered("attribute4"),
          .unordered("attribute5"),
        ]
      )
      .set(
        \.attributesForFaceting,
        to: [.default("attribute1"), .filterOnly("attribute2"), .searchable("attribute3")]
      )
      .set(\.unretrievableAttributes, to: ["attribute1", "attribute2"])
      .set(\.attributesToRetrieve, to: ["attribute3", "attribute4"])
      .set(
        \.ranking,
        to: [
          .asc("attribute1"), .desc("attribute2"), .attribute, .custom, .exact, .filters, .geo,
          .proximity, .typo, .words,
        ]
      )
      .set(\.customRanking, to: [.asc("attribute1"), .desc("attribute1")])
      .set(\.replicas, to: ["\(index.name.rawValue)_replica1", "\(index.name.rawValue)_replica2"])
      .set(\.maxValuesPerFacet, to: 100)
      .set(\.sortFacetsBy, to: .count)
      .set(\.attributesToHighlight, to: ["attribute1", "attribute2"])
      .set(
        \.attributesToSnippet,
        to: [.init(attribute: "attribute1", count: 10), .init(attribute: "attribute2", count: 8)]
      )
      .set(\.highlightPreTag, to: "<strong>")
      .set(\.highlightPostTag, to: "</string>")
      .set(\.snippetEllipsisText, to: " and so on.")
      .set(\.restrictHighlightAndSnippetArrays, to: true)
      .set(\.hitsPerPage, to: 42)
      .set(\.paginationLimitedTo, to: 43)
      .set(\.minWordSizeFor1Typo, to: 2)
      .set(\.minWordSizeFor2Typos, to: 6)
      .set(\.typoTolerance, to: false)
      .set(\.allowTyposOnNumericTokens, to: false)
      .set(\.ignorePlurals, to: false)
      .set(\.disableTypoToleranceOnAttributes, to: ["attribute1", "attribute2"])
      .set(\.disableTypoToleranceOnWords, to: ["word1", "word2"])
      .set(\.separatorsToIndex, to: "()[]")
      .set(\.queryType, to: .prefixNone)
      .set(\.removeWordsIfNoResults, to: .allOptional)
      .set(\.advancedSyntax, to: true)
      .set(\.optionalWords, to: ["word1", "word2"])
      .set(\.removeStopWords, to: true)
      .set(\.disablePrefixOnAttributes, to: ["attribute1", "attribute2"])
      .set(\.disableExactOnAttributes, to: ["attribute1", "attribute2"])
      .set(\.exactOnSingleWordQuery, to: .word)
      .set(\.enableRules, to: false)
      .set(\.numericAttributesForFiltering, to: [.default("attribute1"), .default("attribute2")])
      .set(\.allowCompressionOfIntegerArray, to: true)
      .set(\.attributeForDistinct, to: "attribute1")
      .set(\.distinct, to: 2)
      .set(\.replaceSynonymsInHighlight, to: false)
      .set(\.minProximity, to: 7)
      .set(\.responseFields, to: [.hits, .hitsPerPage])
      .set(\.maxFacetHits, to: 100)
      .set(\.camelCaseAttributes, to: ["attribute1", "attribute2"])
      .set(
        \.decompoundedAttributes,
        to: [.german: ["attribute1", "attribute2"], .finnish: ["attribute3"]]
      )
      .set(\.keepDiacriticsOnCharacters, to: "øé")
      .set(\.queryLanguages, to: [.english, .french])
      .set(\.alternativesAsExact, to: [.ignorePlurals])
      .set(\.advancedSyntaxFeatures, to: [.exactPhrase])
      .set(\.userData, to: ["customUserData": 42])
      .set(\.indexLanguages, to: [.japanese])
      .set(\.customNormalization, to: ["default": ["ä": "ae", "ö": "oe"]])

    try index.setSettings(settings).wait()

    var fetchedSettings = try index.getSettings()

    XCTAssertEqual(
      fetchedSettings.searchableAttributes,
      [
        "attribute1", "attribute2", "attribute3", .unordered("attribute4"),
        .unordered("attribute5"),
      ])
    XCTAssertEqual(
      fetchedSettings.attributesForFaceting,
      [.default("attribute1"), .filterOnly("attribute2"), .searchable("attribute3")])
    XCTAssertEqual(fetchedSettings.unretrievableAttributes, ["attribute1", "attribute2"])
    XCTAssertEqual(fetchedSettings.attributesToRetrieve, ["attribute3", "attribute4"])
    XCTAssertEqual(
      fetchedSettings.ranking,
      [
        .asc("attribute1"), .desc("attribute2"), .attribute, .custom, .exact, .filters, .geo,
        .proximity, .typo, .words,
      ])
    XCTAssertEqual(fetchedSettings.customRanking, [.asc("attribute1"), .desc("attribute1")])
    XCTAssertEqual(
      fetchedSettings.replicas,
      ["\(index.name.rawValue)_replica1", "\(index.name.rawValue)_replica2"])
    XCTAssertEqual(fetchedSettings.maxValuesPerFacet, 100)
    XCTAssertEqual(fetchedSettings.sortFacetsBy, .count)
    XCTAssertEqual(fetchedSettings.attributesToHighlight, ["attribute1", "attribute2"])
    XCTAssertEqual(
      fetchedSettings.attributesToSnippet,
      [.init(attribute: "attribute1", count: 10), .init(attribute: "attribute2", count: 8)])
    XCTAssertEqual(fetchedSettings.highlightPreTag, "<strong>")
    XCTAssertEqual(fetchedSettings.highlightPostTag, "</string>")
    XCTAssertEqual(fetchedSettings.snippetEllipsisText, " and so on.")
    XCTAssertEqual(fetchedSettings.restrictHighlightAndSnippetArrays, true)
    XCTAssertEqual(fetchedSettings.hitsPerPage, 42)
    XCTAssertEqual(fetchedSettings.paginationLimitedTo, 43)
    XCTAssertEqual(fetchedSettings.minWordSizeFor1Typo, 2)
    XCTAssertEqual(fetchedSettings.minWordSizeFor2Typos, 6)
    XCTAssertEqual(fetchedSettings.typoTolerance, false)
    XCTAssertEqual(fetchedSettings.allowTyposOnNumericTokens, false)
    XCTAssertEqual(fetchedSettings.ignorePlurals, false)
    XCTAssertEqual(fetchedSettings.disableTypoToleranceOnAttributes, ["attribute1", "attribute2"])
    XCTAssertEqual(fetchedSettings.disableTypoToleranceOnWords, ["word1", "word2"])
    XCTAssertEqual(fetchedSettings.separatorsToIndex, "()[]")
    XCTAssertEqual(fetchedSettings.queryType, .prefixNone)
    XCTAssertEqual(fetchedSettings.removeWordsIfNoResults, .allOptional)
    XCTAssertEqual(fetchedSettings.advancedSyntax, true)
    XCTAssertEqual(fetchedSettings.optionalWords, ["word1", "word2"])
    XCTAssertEqual(fetchedSettings.removeStopWords, true)
    XCTAssertEqual(fetchedSettings.disablePrefixOnAttributes, ["attribute1", "attribute2"])
    XCTAssertEqual(fetchedSettings.disableExactOnAttributes, ["attribute1", "attribute2"])
    XCTAssertEqual(fetchedSettings.exactOnSingleWordQuery, .word)
    XCTAssertEqual(fetchedSettings.enableRules, false)
    XCTAssertEqual(
      fetchedSettings.numericAttributesForFiltering,
      [.default("attribute1"), .default("attribute2")])
    XCTAssertEqual(fetchedSettings.allowCompressionOfIntegerArray, true)
    XCTAssertEqual(fetchedSettings.attributeForDistinct, "attribute1")
    XCTAssertEqual(fetchedSettings.distinct, 2)
    XCTAssertEqual(fetchedSettings.replaceSynonymsInHighlight, false)
    XCTAssertEqual(fetchedSettings.minProximity, 7)
    XCTAssertEqual(fetchedSettings.responseFields, [.hits, .hitsPerPage])
    XCTAssertEqual(fetchedSettings.maxFacetHits, 100)
    XCTAssertEqual(fetchedSettings.camelCaseAttributes, ["attribute1", "attribute2"])
    XCTAssertEqual(
      fetchedSettings.decompoundedAttributes,
      [.german: ["attribute1", "attribute2"], .finnish: ["attribute3"]])
    XCTAssertEqual(fetchedSettings.keepDiacriticsOnCharacters, "øé")
    XCTAssertEqual(fetchedSettings.queryLanguages, [.english, .french])
    XCTAssertEqual(fetchedSettings.alternativesAsExact, [.ignorePlurals])
    XCTAssertEqual(fetchedSettings.advancedSyntaxFeatures, [.exactPhrase])
    XCTAssertEqual(fetchedSettings.userData, ["customUserData": 42])
    XCTAssertEqual(fetchedSettings.indexLanguages, [.japanese])
    XCTAssertEqual(fetchedSettings.customNormalization, ["default": ["ä": "ae", "ö": "oe"]])

    try index.setSettings(
      settings
        .set(\.typoTolerance, to: .min)
        .set(\.ignorePlurals, to: [.english, .french])
        .set(\.removeStopWords, to: [.english, .french])
        .set(\.distinct, to: true)
    ).wait()

    fetchedSettings = try index.getSettings()

    XCTAssertEqual(
      fetchedSettings.searchableAttributes,
      [
        "attribute1", "attribute2", "attribute3", .unordered("attribute4"),
        .unordered("attribute5"),
      ])
    XCTAssertEqual(
      fetchedSettings.attributesForFaceting,
      [.default("attribute1"), .filterOnly("attribute2"), .searchable("attribute3")])
    XCTAssertEqual(fetchedSettings.unretrievableAttributes, ["attribute1", "attribute2"])
    XCTAssertEqual(fetchedSettings.attributesToRetrieve, ["attribute3", "attribute4"])
    XCTAssertEqual(
      fetchedSettings.ranking,
      [
        .asc("attribute1"), .desc("attribute2"), .attribute, .custom, .exact, .filters, .geo,
        .proximity, .typo, .words,
      ])
    XCTAssertEqual(fetchedSettings.customRanking, [.asc("attribute1"), .desc("attribute1")])
    XCTAssertEqual(
      fetchedSettings.replicas,
      ["\(index.name.rawValue)_replica1", "\(index.name.rawValue)_replica2"])
    XCTAssertEqual(fetchedSettings.maxValuesPerFacet, 100)
    XCTAssertEqual(fetchedSettings.sortFacetsBy, .count)
    XCTAssertEqual(fetchedSettings.attributesToHighlight, ["attribute1", "attribute2"])
    XCTAssertEqual(
      fetchedSettings.attributesToSnippet,
      [.init(attribute: "attribute1", count: 10), .init(attribute: "attribute2", count: 8)])
    XCTAssertEqual(fetchedSettings.highlightPreTag, "<strong>")
    XCTAssertEqual(fetchedSettings.highlightPostTag, "</string>")
    XCTAssertEqual(fetchedSettings.snippetEllipsisText, " and so on.")
    XCTAssertEqual(fetchedSettings.restrictHighlightAndSnippetArrays, true)
    XCTAssertEqual(fetchedSettings.hitsPerPage, 42)
    XCTAssertEqual(fetchedSettings.paginationLimitedTo, 43)
    XCTAssertEqual(fetchedSettings.minWordSizeFor1Typo, 2)
    XCTAssertEqual(fetchedSettings.minWordSizeFor2Typos, 6)
    XCTAssertEqual(fetchedSettings.typoTolerance, .min)
    XCTAssertEqual(fetchedSettings.allowTyposOnNumericTokens, false)
    XCTAssertEqual(fetchedSettings.ignorePlurals, [.english, .french])
    XCTAssertEqual(fetchedSettings.disableTypoToleranceOnAttributes, ["attribute1", "attribute2"])
    XCTAssertEqual(fetchedSettings.disableTypoToleranceOnWords, ["word1", "word2"])
    XCTAssertEqual(fetchedSettings.separatorsToIndex, "()[]")
    XCTAssertEqual(fetchedSettings.queryType, .prefixNone)
    XCTAssertEqual(fetchedSettings.removeWordsIfNoResults, .allOptional)
    XCTAssertEqual(fetchedSettings.advancedSyntax, true)
    XCTAssertEqual(fetchedSettings.optionalWords, ["word1", "word2"])
    XCTAssertEqual(fetchedSettings.removeStopWords, [.english, .french])
    XCTAssertEqual(fetchedSettings.disablePrefixOnAttributes, ["attribute1", "attribute2"])
    XCTAssertEqual(fetchedSettings.disableExactOnAttributes, ["attribute1", "attribute2"])
    XCTAssertEqual(fetchedSettings.exactOnSingleWordQuery, .word)
    XCTAssertEqual(fetchedSettings.enableRules, false)
    XCTAssertEqual(
      fetchedSettings.numericAttributesForFiltering,
      [.default("attribute1"), .default("attribute2")])
    XCTAssertEqual(fetchedSettings.allowCompressionOfIntegerArray, true)
    XCTAssertEqual(fetchedSettings.attributeForDistinct, "attribute1")
    XCTAssertEqual(fetchedSettings.distinct, true)
    XCTAssertEqual(fetchedSettings.replaceSynonymsInHighlight, false)
    XCTAssertEqual(fetchedSettings.minProximity, 7)
    XCTAssertEqual(fetchedSettings.responseFields, [.hits, .hitsPerPage])
    XCTAssertEqual(fetchedSettings.maxFacetHits, 100)
    XCTAssertEqual(fetchedSettings.camelCaseAttributes, ["attribute1", "attribute2"])
    XCTAssertEqual(
      fetchedSettings.decompoundedAttributes,
      [.german: ["attribute1", "attribute2"], .finnish: ["attribute3"]])
    XCTAssertEqual(fetchedSettings.keepDiacriticsOnCharacters, "øé")
    XCTAssertEqual(fetchedSettings.queryLanguages, [.english, .french])
    XCTAssertEqual(fetchedSettings.alternativesAsExact, [.ignorePlurals])
    XCTAssertEqual(fetchedSettings.advancedSyntaxFeatures, [.exactPhrase])
    XCTAssertEqual(fetchedSettings.userData, ["customUserData": 42])
    XCTAssertEqual(fetchedSettings.indexLanguages, [.japanese])
    XCTAssertEqual(fetchedSettings.customNormalization, ["default": ["ä": "ae", "ö": "oe"]])
  }
}
