//
//  CopyIndexIntergrationTests.swift
//  
//
//  Created by Vladislav Fitc on 22/04/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

@available(iOS 15.0.0, *)
class CopyIndexIntergrationTests: IntegrationTestCase {

  var sourceIndex: Index {
    return index!
  }
  
  override var retryableAsyncTests: [() async throws -> Void]{
    [
      copySettings,
      copyRules,
      copySynonyms,
      fullCopy
    ]
  }
  
  let records: [JSON] = [
    ["objectID": "one", "company": "apple"],
    ["objectID": "two", "company": "algolia"]
  ]
  
  let settings = Settings().set(\.attributesForFaceting, to: ["company"])
  let rule = Rule(objectID: "company_auto_faceting")
    .set(\.conditions, to: [.init(anchoring: .contains, pattern: .facet("company"))])
    .set(\.consequence, to: Rule.Consequence().set(\.automaticFacetFilters, to: [Rule.AutomaticFacetFilters(attribute: "company")]))
  let synonym = Synonym.placeholder(objectID: "google_placeholder", placeholder: "<GOOG>", replacements: ["Google", "GOOG"])
      
  func copySettings() async throws {
    
    let targetIndex = client.index(withName: "copy_index_settings")
    
    try await sourceIndex.saveObjects(records).wait()
    try await sourceIndex.setSettings(settings).wait()
    
    try await sourceIndex.copy(.settings, to: targetIndex.name).wait()
    
    let fetchedSettings = try await targetIndex.getSettings()

    XCTAssertEqual(settings.attributesForFaceting, fetchedSettings.attributesForFaceting)
    
    try await targetIndex.delete().wait()
    
  }
  
  func copyRules() async throws {
    
    let targetIndex = client.index(withName: "copy_index_rules")
    
    try sourceIndex.saveRule(rule).wait()
    
    try await sourceIndex.copy(.rules, to: targetIndex.name).wait()

    let fetchedRules = try await targetIndex.searchRules("").hits.map(\.rule)
    
    XCTAssertEqual(fetchedRules.count, 1)
    try AssertEquallyEncoded(fetchedRules.first!, rule)
    
    try await targetIndex.delete().wait()


  }
  
  func copySynonyms() async throws {
    
    let targetIndex = client.index(withName: "copy_index_synonyms")
    
    try sourceIndex.saveSynonym(synonym).wait()
    
    try await sourceIndex.copy(.synonyms, to: targetIndex.name).wait()

    let fetchedSynonyms = try await targetIndex.searchSynonyms("").hits.map(\.synonym)
    
    XCTAssertEqual(fetchedSynonyms.count, 1)
    try AssertEquallyEncoded(fetchedSynonyms.first!, synonym)
    
    try await targetIndex.delete().wait()
    
  }
  
  func fullCopy() async throws {
    
    let targetIndex = client.index(withName: "copy_index_full_copy")
    
    try await sourceIndex.saveObjects(records).wait()
    try await sourceIndex.setSettings(settings).wait()
    try sourceIndex.saveRule(rule).wait()
    try sourceIndex.saveSynonym(synonym).wait()
    
    try await sourceIndex.copy(to: targetIndex.name).wait()
    
    let fullCopyRecords = try await targetIndex.browse().hits.map(\.object)
    
    for record in records {
      XCTAssert(fullCopyRecords.contains(record))
    }
    
    let fullCopySettings = try await targetIndex.getSettings()
    XCTAssertEqual(settings.attributesForFaceting, fullCopySettings.attributesForFaceting)
    
    let fullCopyRules = try await targetIndex.searchRules("").hits.map(\.rule)
    XCTAssertEqual(fullCopyRules.count, 1)
    try AssertEquallyEncoded(fullCopyRules.first!, rule)
    
    let fullCopySynonyms = try await targetIndex.searchSynonyms("").hits.map(\.synonym)
    XCTAssertEqual(fullCopySynonyms.count, 1)
    try AssertEquallyEncoded(fullCopySynonyms.first!, synonym)
        
    try await targetIndex.delete().wait()

  }
  
}
