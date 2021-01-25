//
//  DictionairesIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 21/01/2021.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class DictionairesIntegrationTests: OnlineTestCase {
    
  override func setUpWithError() throws {
    let fetchedCredentials = Result(catching: { try TestCredentials(environment: .secondary) }).mapError { XCTSkip("\($0)") }
    let credentials = try fetchedCredentials.get()
    client = SearchClient(appID: credentials.applicationID, apiKey: credentials.apiKey)
  }
  
  func testStopwordsDictionary() throws {
    
    // Create one `entry_id` with a random string
    let entryID = ObjectID(rawValue: .random(length: 10))

    // Search in the `compounds` dictionary with **search_dictionary_entries** for the entry_id and assert that the result count is 0
    var response: DictionarySearchResponse<StopWord> = try client.searchDictionaryEntries(dictionaryName: .stopwords, query: "\(entryID)")
    XCTAssert(response.hits.isEmpty)
    
    // Add the following entry in the `compounds` dictionary with **save_dictionary_entries** and wait for the task to finish
    let stopwordEntry = StopWord(objectID: entryID, language: .english, word: "down", state: .enabled)
    try client.saveDictionaryEntries([stopwordEntry]).wait()

    // Search in the `compounds` dictionary with **search_dictionary_entries** for the entry_id and assert that the result count is 1
    response = try client.searchDictionaryEntries(dictionaryName: .stopwords, query: "\(entryID)")
    XCTAssertEqual(response.nbHits, 1)
    
    // Assert that the retrieved entry matches the saved one
    let hit = response.hits.first!
    XCTAssertEqual(hit.objectID, stopwordEntry.objectID)
    XCTAssertEqual(hit.language, stopwordEntry.language)
    XCTAssertEqual(hit.word, stopwordEntry.word)
    XCTAssertEqual(hit.state, stopwordEntry.state)

    // Delete the entry with **delete_dictionary_entries** and wait for the task to finish
    try client.deleteDictionaryEntries(dictionaryName: .stopwords, withObjectIDs: [entryID]).wait()

    // Search in the `compounds` dictionary with **search_dictionary_entries** for the entry_id and assert that the result count is 0
    response = try client.searchDictionaryEntries(dictionaryName: .stopwords, query: "\(entryID)")
    XCTAssert(response.hits.isEmpty)
    
    // Retrieve the current dictionary entries and store them in a variable
    let previousEntries: [StopWord] = try client.searchDictionaryEntries(dictionaryName: .stopwords, query: "").hits

    // Add the following entry in the `stopwords` dictionary with **save_dictionary_entries** and wait for the task to finish
    try client.saveDictionaryEntries([stopwordEntry]).wait()

    // Search in the `stopwords` dictionary with **search_dictionary_entries** for the entry_id and assert that the result count is 1
    response = try client.searchDictionaryEntries(dictionaryName: .stopwords, query: "\(entryID)")
    XCTAssertEqual(response.nbHits, 1)

    // Replace all the entries in the `stopwords` dictionary with the previously stored entries
    try client.replaceDictionaryEntries(with: previousEntries).wait()
    
    // Search in the `stopwords` dictionary with **search_dictionary_entries** for the entry_id and assert that the result count is 0
    response = try client.searchDictionaryEntries(dictionaryName: .stopwords, query: "\(entryID)")
    XCTAssert(response.hits.isEmpty)

    // Set dictionaries settings with **set_dictionary_settings** the following settings and wait for the task to finish
    let settings = DictionarySettings(disableStandardEntries: .init(stopwords: [.english: true]))
    try client.setDictionarySettings(settings)

    // Retrieve the dictionary settings with **get_dictionary_settings** and assert the settings match the one saved
    let fetchedSettings = try client.getDictionarySettings()
    XCTAssertEqual(settings, fetchedSettings)
  }
  
  func testCompoundsDictionary() throws {
    // Create one `entry_id` with a random string
    let entryID = ObjectID(rawValue: .random(length: 10))

    // Search in the `compounds` dictionary with **search_dictionary_entries** for the entry_id and assert that the result count is 0
    var response: DictionarySearchResponse<Compound> = try client.searchDictionaryEntries(dictionaryName: .compounds, query: "\(entryID)")
    XCTAssert(response.hits.isEmpty)
    
    // Add the following entry in the `compounds` dictionary with **save_dictionary_entries** and wait for the task to finish
    let compoundEntry = Compound(objectID: entryID, language: .german, word: "kopfschmerztablette", decomposition: ["kopf", "schmerz", "tablette"])
    try client.saveDictionaryEntries([compoundEntry]).wait()

    // Search in the `compounds` dictionary with **search_dictionary_entries** for the entry_id and assert that the result count is 1
    response = try client.searchDictionaryEntries(dictionaryName: .compounds, query: "\(entryID)")
    XCTAssertEqual(response.nbHits, 1)
    
    // Assert that the retrieved entry matches the saved one
    let hit = response.hits.first!
    XCTAssertEqual(hit.objectID, compoundEntry.objectID)
    XCTAssertEqual(hit.language, compoundEntry.language)
    XCTAssertEqual(hit.word, compoundEntry.word)
    XCTAssertEqual(hit.decomposition, compoundEntry.decomposition)

    // Delete the entry with **delete_dictionary_entries** and wait for the task to finish
    try client.deleteDictionaryEntries(dictionaryName: .compounds, withObjectIDs: [entryID]).wait()

    // Search in the `compounds` dictionary with **search_dictionary_entries** for the entry_id and assert that the result count is 0
    response = try client.searchDictionaryEntries(dictionaryName: .compounds, query: "\(entryID)")
    XCTAssert(response.hits.isEmpty)
  }
  
  func testPluralsDictionary() throws {
    // Create one `entry_id` with a random string
    let entryID = ObjectID(rawValue: .random(length: 10))
    
    // Search in the `plurals` dictionary with **search_dictionary_entries** for the entry_id and assert that the result count is 0
    var response: DictionarySearchResponse<Plural> = try client.searchDictionaryEntries(dictionaryName: .plurals, query: "\(entryID)")
    XCTAssert(response.hits.isEmpty)
    
    // Add the following entry in the `plurals` dictionary with **save_dictionary_entries** and wait for the task to finish
    
    let pluralEntry = Plural(objectID: entryID, language: .french, words: ["cheval", "chevaux"])
    try client.saveDictionaryEntries([pluralEntry]).wait()
        
    //  Search in the `plurals` dictionary with **search_dictionary_entries** for the entry_id and assert that the result count is 1
    response = try client.searchDictionaryEntries(dictionaryName: .plurals, query: "\(entryID)")
    XCTAssertEqual(response.nbHits, 1)
    
    // Assert that the retrieved entry matches the saved one
    let hit = response.hits.first!
    XCTAssertEqual(hit.objectID, pluralEntry.objectID)
    XCTAssertEqual(hit.language, pluralEntry.language)
    XCTAssertEqual(hit.words, pluralEntry.words)
    
    // Delete the entry with **delete_dictionary_entries** and wait for the task to finish
    try client.deleteDictionaryEntries(dictionaryName: .plurals, withObjectIDs: [entryID]).wait()
    
    // Search in the `plurals` dictionary with **search_dictionary_entries** for the entry_id and assert that the result count is 0
    response = try client.searchDictionaryEntries(dictionaryName: .plurals, query: "\(entryID)")
    XCTAssert(response.hits.isEmpty)
  }
  
}
