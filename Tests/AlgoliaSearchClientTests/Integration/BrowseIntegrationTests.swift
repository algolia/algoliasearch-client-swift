//
//  BrowseIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 02/07/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

extension StringWrapper {
  static var random: Self {
    return .init(stringLiteral: String.random(length: .random(in: 1...20)))
  }
}

class BrowseIntegrationTests: OnlineTestCase {

  override var indexNameSuffix: String? {
    return "index_browse"
  }
  
  override var retryableTests: [() throws -> Void] {
    [
      browseObjects,
      browseRules,
      browseSynonyms
    ]
  }
  
  func browseObjects() throws {
    
    struct Record: Codable {
      let objectID: String
      let name: String
    }
        
    let records: [Record] = (0...10000).map { _ in
        .init(objectID: .random(length: 5), name: String.random(length: .random(in: 1...20)))
    }
    
    try index.setSettings(Settings().set(\.attributesForFaceting, to: ["metric", "color"]))
    try index.saveObjects(records).wait()
    
    let responses = try index.browseObjects()
    
    let fetchedObjectIDs = responses
      .map { (try? $0.extractHits() as [Record]) }
      .compactMap { $0 }
      .flatMap { $0 }
      .map(\.objectID)
  
    XCTAssertEqual(Set(records.map(\.objectID)) , Set(fetchedObjectIDs))
    
  }
  
  func browseRules() throws {
    
    let rules: [Rule] = (0...50).map { _ in
      return Rule(objectID: .random)
        .set(\.conditions, to: [.init(anchoring: .is, pattern: .literal(.random(length: .random(in: 0...10))))])
        .set(\.consequence, to: Rule.Consequence().set(\.hide, to: [.random, .random]))
    }
    
    try index.saveRules(rules).wait()
    
    let responses = try index.browseRules()
    
    let fetchedRuleIDs = responses.flatMap(\.hits).map(\.rule.objectID)
    
    XCTAssertEqual(Set(rules.map(\.objectID)), Set(fetchedRuleIDs))
    
  }
  
  func browseSynonyms() throws {
    
    let synonyms: [Synonym] = (0...50).map { _ in
      switch Int.random(in: 0...3) {
      case 0:
        return .oneWay(objectID: .random, input: .random, synonyms: [.random, .random, .random])
      case 1:
        return .multiWay(objectID: .random, synonyms: [.random, .random, .random])
      case 2:
        return .alternativeCorrection(objectID: .random, word: .random, corrections: [.random, .random, .random], typo: Bool.random() ? .one : .two)
      default:
        return .placeholder(objectID: .random, placeholder: "<token>", replacements: [.random, .random])
      }
    }
    
    try index.saveSynonyms(synonyms).wait()
            
    let responses = try index.browseSynonyms()

    let fetchedSynonymIDs = responses.flatMap(\.hits).map(\.synonym.objectID)

    XCTAssertEqual(Set(synonyms.map(\.objectID)), Set(fetchedSynonymIDs))
  }

}
