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

    // Search in the `stopwords` dictionary with **search_dictionary_entries** for the entry_id and assert that the result count is 0
    var response = try client.searchDictionaryEntries(in: StopwordsDictionary.self, query: "\(entryID)")
    XCTAssert(response.hits.isEmpty)
    
    // Add the following entry in the `stopwords` dictionary with **save_dictionary_entries** and wait for the task to finish
    let stopwordEntry = StopwordsDictionary.Entry(objectID: entryID, language: .english, word: "down", state: .enabled)
    try client.saveDictionaryEntries(to: StopwordsDictionary.self, dictionaryEntries: [stopwordEntry]).wait()

    // Search in the `stopwords` dictionary with **search_dictionary_entries** for the entry_id and assert that the result count is 1
    response = try client.searchDictionaryEntries(in: StopwordsDictionary.self, query: "\(entryID)")
    XCTAssertEqual(response.nbHits, 1)
    
    // Assert that the retrieved entry matches the saved one
    XCTAssertEqual(response.hits.first!, stopwordEntry)

    // Delete the entry with **delete_dictionary_entries** and wait for the task to finish
    try client.deleteDictionaryEntries(from: StopwordsDictionary.self, withObjectIDs: [entryID]).wait()

    // Search in the `stopwords` dictionary with **search_dictionary_entries** for the entry_id and assert that the result count is 0
    response = try client.searchDictionaryEntries(in: StopwordsDictionary.self, query: "\(entryID)")
    XCTAssert(response.hits.isEmpty)
    
    // Retrieve the current dictionary entries and store them in a variable
    let previousEntries = try client.searchDictionaryEntries(in: StopwordsDictionary.self, query: "").hits

    // Add the following entry in the `stopwords` dictionary with **save_dictionary_entries** and wait for the task to finish
    try client.saveDictionaryEntries(to: StopwordsDictionary.self, dictionaryEntries: [stopwordEntry]).wait()

    // Search in the `stopwords` dictionary with **search_dictionary_entries** for the entry_id and assert that the result count is 1
    response = try client.searchDictionaryEntries(in: StopwordsDictionary.self, query: "\(entryID)")
    XCTAssertEqual(response.nbHits, 1)

    // Replace all the entries in the `stopwords` dictionary with the previously stored entries
    try client.replaceDictionaryEntries(in: StopwordsDictionary.self, with: previousEntries) .wait()
    
    // Search in the `stopwords` dictionary with **search_dictionary_entries** for the entry_id and assert that the result count is 0
    response = try client.searchDictionaryEntries(in: StopwordsDictionary.self, query: "\(entryID)")
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
    var response = try client.searchDictionaryEntries(in: CompoundsDictionary.self, query: "\(entryID)")
    XCTAssert(response.hits.isEmpty)
    
    // Add the following entry in the `compounds` dictionary with **save_dictionary_entries** and wait for the task to finish
    let compoundEntry = CompoundsDictionary.Entry(objectID: entryID, language: .german, word: "kopfschmerztablette", decomposition: ["kopf", "schmerz", "tablette"])
    try client.saveDictionaryEntries(to: CompoundsDictionary.self, dictionaryEntries: [compoundEntry]).wait()

    // Search in the `compounds` dictionary with **search_dictionary_entries** for the entry_id and assert that the result count is 1
    response = try client.searchDictionaryEntries(in: CompoundsDictionary.self, query: "\(entryID)")
    XCTAssertEqual(response.nbHits, 1)
    
    // Assert that the retrieved entry matches the saved one
    XCTAssertEqual(response.hits.first!, compoundEntry)

    // Delete the entry with **delete_dictionary_entries** and wait for the task to finish
    try client.deleteDictionaryEntries(from: CompoundsDictionary.self, withObjectIDs: [entryID]).wait()

    // Search in the `compounds` dictionary with **search_dictionary_entries** for the entry_id and assert that the result count is 0
    response = try client.searchDictionaryEntries(in: CompoundsDictionary.self, query: "\(entryID)")
    XCTAssert(response.hits.isEmpty)
  }
  
  func testPluralsDictionary() throws {
    // Create one `entry_id` with a random string
    let entryID = ObjectID(rawValue: .random(length: 10))
    
    // Search in the `plurals` dictionary with **search_dictionary_entries** for the entry_id and assert that the result count is 0
    var response = try client.searchDictionaryEntries(in: PluralsDictionary.self, query: "\(entryID)")
    XCTAssert(response.hits.isEmpty)
    
    // Add the following entry in the `plurals` dictionary with **save_dictionary_entries** and wait for the task to finish
    let pluralEntry = PluralsDictionary.Entry(objectID: entryID, language: .french, words: ["cheval", "chevaux"])
    try client.saveDictionaryEntries(to: PluralsDictionary.self, dictionaryEntries: [pluralEntry]).wait()
        
    //  Search in the `plurals` dictionary with **search_dictionary_entries** for the entry_id and assert that the result count is 1
    response = try client.searchDictionaryEntries(in: PluralsDictionary.self, query: "\(entryID)")
    XCTAssertEqual(response.nbHits, 1)
    
    // Assert that the retrieved entry matches the saved one
    XCTAssertEqual(response.hits.first!, pluralEntry)

    // Delete the entry with **delete_dictionary_entries** and wait for the task to finish
    try client.deleteDictionaryEntries(from: PluralsDictionary.self, withObjectIDs: [entryID]).wait()
    
    // Search in the `plurals` dictionary with **search_dictionary_entries** for the entry_id and assert that the result count is 0
    response = try client.searchDictionaryEntries(in: PluralsDictionary.self, query: "\(entryID)")
    XCTAssert(response.hits.isEmpty)
  }
  
}
