//
//  SynonymsIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 20/05/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

@available(iOS 15.0.0, *)
class SynonymsIntegrationTests: IntegrationTestCase {

  override var indexNameSuffix: String? { return "synonyms" }
  
  override var retryableAsyncTests: [() async throws -> Void] {
    [synonyms]
  }

  func synonyms() async throws {
    
    let records: [JSON] = [
      ["console": "Sony PlayStation <PLAYSTATIONVERSION>"],
      ["console": "Nintendo Switch"],
      ["console": "Nintendo Wii U"],
      ["console": "Nintendo Game Boy Advance"],
      ["console": "Microsoft Xbox"],
      ["console": "Microsoft Xbox 360"],
      ["console": "Microsoft Xbox One"],
    ]
    
    try await index.saveObjects(records, autoGeneratingObjectID: true).wait()
    
    let multiWaySynonym: Synonym = .multiWay(objectID: "gba", synonyms: ["gba", "gameboy advance", "game boy advance"])
    
    try index.saveSynonym(multiWaySynonym).wait()
    let oneWaySynonym: Synonym = .oneWay(objectID: "wii_to_wii_u", input: "wii", synonyms: ["wii U"])
    let placeholderSynonym: Synonym = .placeholder(objectID: "playstation_version_placeholder", placeholder: "<PLAYSTATIONVERSION>", replacements: ["1", "One", "2", "3", "4", "4 Pro"])
    let altCorrection1Synonym: Synonym = .alternativeCorrection(objectID: "ps4", word: "ps4", corrections: ["playstation4"], typo: .one)
    let altCorrection2Synonym: Synonym = .alternativeCorrection(objectID: "psone", word: "psone", corrections: ["playstationone"], typo: .two)

    let synonyms: [Synonym] = [
      oneWaySynonym,
      placeholderSynonym,
      altCorrection1Synonym,
      altCorrection2Synonym
    ]

    try index.saveSynonyms(synonyms).wait()
    
    let fetchedMultiWay = try index.getSynonym(withID: multiWaySynonym.objectID)
    try AssertEquallyEncoded(fetchedMultiWay, multiWaySynonym)
    
    let fetchedOneWay = try index.getSynonym(withID: oneWaySynonym.objectID)
    try AssertEquallyEncoded(fetchedOneWay, oneWaySynonym)
    
    let fetchedPlaceholder = try index.getSynonym(withID: placeholderSynonym.objectID)
    try AssertEquallyEncoded(fetchedPlaceholder, placeholderSynonym)
    
    let fetchedAltCorrection1 = try index.getSynonym(withID: altCorrection1Synonym.objectID)
    try AssertEquallyEncoded(fetchedAltCorrection1, altCorrection1Synonym)

    let fetchedAltCorrection2 = try index.getSynonym(withID: altCorrection2Synonym.objectID)
    try AssertEquallyEncoded(fetchedAltCorrection2, altCorrection2Synonym)
    
    let fetchedSynonyms = try index.searchSynonyms("").hits.map(\.synonym)
    XCTAssertEqual(fetchedSynonyms.count, 5)

    try AssertEquallyEncoded(fetchedSynonyms.first(where: { $0.objectID == multiWaySynonym.objectID}), multiWaySynonym)
    try AssertEquallyEncoded(fetchedSynonyms.first(where: { $0.objectID == oneWaySynonym.objectID}), oneWaySynonym)
    try AssertEquallyEncoded(fetchedSynonyms.first(where: { $0.objectID == placeholderSynonym.objectID}), placeholderSynonym)
    try AssertEquallyEncoded(fetchedSynonyms.first(where: { $0.objectID == altCorrection1Synonym.objectID}), altCorrection1Synonym)
    try AssertEquallyEncoded(fetchedSynonyms.first(where: { $0.objectID == altCorrection2Synonym.objectID}), altCorrection2Synonym)

    try index.deleteSynonym(withID: multiWaySynonym.objectID).wait()
    try await AssertThrowsHTTPError(index.getSynonym(withID: multiWaySynonym.objectID), statusCode: 404)
    
    try index.clearSynonyms().wait()
    try await AssertThrowsHTTPError(index.getSynonym(withID: oneWaySynonym.objectID), statusCode: 404)
    try await AssertThrowsHTTPError(index.getSynonym(withID: placeholderSynonym.objectID), statusCode: 404)
    try await AssertThrowsHTTPError(index.getSynonym(withID: altCorrection1Synonym.objectID), statusCode: 404)
    try await AssertThrowsHTTPError(index.getSynonym(withID: altCorrection2Synonym.objectID), statusCode: 404)
    
    XCTAssertEqual(try index.searchSynonyms("").nbHits, 0)

  }
  
}

