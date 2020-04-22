//
//  CopyIndexIntergrationTests.swift
//  
//
//  Created by Vladislav Fitc on 22/04/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class CopyIndexIntergrationTests: OnlineTestCase {
  
  override var indexNameSuffix: String? {
    "copyIndex"
  }

  var sourceIndex: Index {
    return index!
  }
  
  let records: [JSON] = [
    ["objectID": "one", "company": "apple"],
    ["objectID": "two", "company": "algolia"]
  ]
  
  let settings = Settings().set(\.attributesForFaceting, to: ["company"])
      
  func testCopySettings() throws {
    
    let targetIndex = client.index(withName: "copy_index_settings")
    
    try sourceIndex.saveObjects(records).wait()
    try sourceIndex.setSettings(settings).wait()
    
    try sourceIndex.copy([.settings], to: targetIndex.name).wait()
    
    let fetchedSettings = try targetIndex.getSettings()

    XCTAssertEqual(settings.attributesForFaceting, fetchedSettings.attributesForFaceting)
    
    try targetIndex.delete().wait()
    
  }
  
  func testCopyRules() {
    //TODO
  }
  
  func testCopySynonyms() {
    //TODO
  }
  
  func testFullCopy() throws {
    
    let targetIndex = client.index(withName: "copy_index_full_copy")
    
    try sourceIndex.saveObjects(records).wait()
    try sourceIndex.setSettings(settings).wait()
    
    try sourceIndex.copy(to: targetIndex.name).wait()
    
    let fullCopyRecords = try targetIndex.browse().hits.map(\.object)
    
    for record in records {
      XCTAssert(fullCopyRecords.contains(record))
    }
    
    let fullCopySettings = try targetIndex.getSettings()
    XCTAssertEqual(settings.attributesForFaceting, fullCopySettings.attributesForFaceting)
    
    //TODO: Check rules
    //TODO: Check synonyms
    
    try targetIndex.delete().wait()

  }
  
}
