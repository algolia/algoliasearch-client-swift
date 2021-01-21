//
//  DictionaryCommandTests.swift
//  
//
//  Created by Vladislav Fitc on 21/01/2021.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class DictionaryCommandsTests: XCTestCase, AlgoliaCommandTest {

  func testBatch() {
    let requests = [
      StopWord(objectID: "o1",
               language: .english,
               word: "stop1",
               state: .enabled),
      StopWord(objectID: "o2",
               language: .english,
               word: "stop2",
               state: .disabled)
    ].map { DictionaryRequest.addEntry($0) }

    let command = Command.Dictionaries.Batch(requests: requests,
                                             clearExistingDictionaryEntries: true,
                                             requestOptions: test.requestOptions)
    let payload = Command.Dictionaries.Batch.Payload(requests: requests,
                                                     clearExistingDictionaryEntries: true)
    check(command: command,
          callType: .write,
          method: .post,
          urlPath: "/1/dictionaries/stopwords/batch",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: payload.httpBody,
          requestOptions: test.requestOptions)
  }
  
  func testSearch() {
    let command = Command.Dictionaries.Search(dictionaryName: .compounds,
                                              query: "test query",
                                              requestOptions: test.requestOptions)
    check(command: command,
          callType: .read,
          method: .post,
          urlPath: "/1/dictionaries/compounds/search",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: DictionaryQuery(query: "test query").httpBody,
          requestOptions: test.requestOptions)
  }
  
  func testGetSettings() {
    let command = Command.Dictionaries.GetSettings(requestOptions: test.requestOptions)
    check(command: command,
          callType: .read,
          method: .get,
          urlPath: "/1/dictionaries/*/settings",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: nil,
          requestOptions: test.requestOptions)
  }
  
  func testSetSettings() {
    let settings = DictionarySettings(stopwords: DictionarySettings.StopWords(disableStandardEntries: [.french: true]))
    let command = Command.Dictionaries.SetSettings(settings: settings, requestOptions: test.requestOptions)
    check(command: command,
          callType: .write,
          method: .put,
          urlPath: "/1/dictionaries/*/settings",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: settings.httpBody,
          requestOptions: test.requestOptions)
  }
  
  func testLanguagesList() {
    let command = Command.Dictionaries.LanguagesList(requestOptions: test.requestOptions)
    check(command: command,
          callType: .read,
          method: .get,
          urlPath: "/1/dictionaries/*/languages",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: nil,
          requestOptions: test.requestOptions)
  }

}
