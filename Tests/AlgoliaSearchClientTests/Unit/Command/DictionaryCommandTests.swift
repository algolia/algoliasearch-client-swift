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

    let command = Command.Dictionaries.Batch(requests: requests, clearExistingDictionaryEntries: true, requestOptions: test.requestOptions)
    check(command: command,
          callType: .write,
          method: .post,
          urlPath: "/1/dictionaries/stopwords/batch",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: requests.httpBody,
          requestOptions: test.requestOptions)
  }

}
