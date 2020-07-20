//
//  CopyIndexIntergrationTests.swift
//  
//
//  Created by Vladislav Fitc on 22/04/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class CopyIndexIntergrationTests: OnlineTestCase {

  var sourceIndex: Index {
    return index!
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
      
  func testCopySettings() throws {
    
    let targetIndex = client.index(withName: "copy_index_settings")
    
    try sourceIndex.saveObjects(records).wait()
    try sourceIndex.setSettings(settings).wait()
    
    try sourceIndex.copy(.settings, to: targetIndex.name).wait()
    
    let fetchedSettings = try targetIndex.getSettings()

    XCTAssertEqual(settings.attributesForFaceting, fetchedSettings.attributesForFaceting)
    
    try targetIndex.delete().wait()
    
  }
  
  func testCopyRules() throws {
    
    let targetIndex = client.index(withName: "copy_index_rules")
    
    try sourceIndex.saveRule(rule).wait()
    
    try sourceIndex.copy(.rules, to: targetIndex.name).wait()

    let fetchedRules = try targetIndex.searchRules("").hits.map(\.rule)
    
    XCTAssertEqual(fetchedRules.count, 1)
    try AssertEquallyEncoded(fetchedRules.first!, rule)
    
    try targetIndex.delete().wait()


  }
  
  func testCopySynonyms() throws {
    
    let targetIndex = client.index(withName: "copy_index_synonyms")
    
    try sourceIndex.saveSynonym(synonym).wait()
    
    try sourceIndex.copy(.synonyms, to: targetIndex.name).wait()

    let fetchedSynonyms = try targetIndex.searchSynonyms("").hits.map(\.synonym)
    
    XCTAssertEqual(fetchedSynonyms.count, 1)
    try AssertEquallyEncoded(fetchedSynonyms.first!, synonym)
    
    try targetIndex.delete().wait()
    
  }
  
  func testFullCopy() throws {
    
    let targetIndex = client.index(withName: "copy_index_full_copy")
    
    try sourceIndex.saveObjects(records).wait()
    try sourceIndex.setSettings(settings).wait()
    try sourceIndex.saveRule(rule).wait()
    try sourceIndex.saveSynonym(synonym).wait()
    
    try sourceIndex.copy(to: targetIndex.name).wait()
    
    let fullCopyRecords = try targetIndex.browse().hits.map(\.object)
    
    for record in records {
      XCTAssert(fullCopyRecords.contains(record))
    }
    
    let fullCopySettings = try targetIndex.getSettings()
    XCTAssertEqual(settings.attributesForFaceting, fullCopySettings.attributesForFaceting)
    
    let fullCopyRules = try targetIndex.searchRules("").hits.map(\.rule)
    XCTAssertEqual(fullCopyRules.count, 1)
    try AssertEquallyEncoded(fullCopyRules.first!, rule)
    
    let fullCopySynonyms = try targetIndex.searchSynonyms("").hits.map(\.synonym)
    XCTAssertEqual(fullCopySynonyms.count, 1)
    try AssertEquallyEncoded(fullCopySynonyms.first!, synonym)
        
    try targetIndex.delete().wait()

  }
  
}
