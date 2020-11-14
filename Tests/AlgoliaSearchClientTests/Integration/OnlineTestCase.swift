//
//  OnlineTestCase.swift
//  
//
//  Created by Vladislav Fitc on 05/03/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class OnlineTestCase: XCTestCase {

  var client: SearchClient!
  var index: Index!
  let expectationTimeout: TimeInterval = 100
  let retryCount: Int = 3
  
  var retryableTests: [() throws -> Void] { return [] }
  
  var allowFailure: Bool { return false }

  /// Abstract base class for online test cases.
  ///
  
  var indexNameSuffix: String? {
    return nil
  }
  
  func uniquePrefix() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY-MM-DD_HH:mm:ss"
    let dateString = dateFormatter.string(from: .init())
    return "swift_\(dateString)_\(NSUserName().description)"
  }
  
  var environment: TestCredentials.Environment { .default }

  override func setUpWithError() throws {

    try super.setUpWithError()

    let fetchedCredentials = Result(catching: { try TestCredentials(environment: environment) }).mapError { XCTSkip("\($0)") }
    let credentials = try fetchedCredentials.get()
    
    client = SearchClient(appID: credentials.applicationID, apiKey: credentials.apiKey)
    let indexNameSuffix = self.indexNameSuffix ?? name
    let indexName = IndexName(stringLiteral: "\(uniquePrefix())_\(indexNameSuffix)")
    index = client.index(withName: indexName)

    try index.delete()
  }
  
  func testRetryable() throws {
    for test in retryableTests {
      for attemptCount in 1...retryCount {
        do {
          try test()
          break
        } catch let error where attemptCount == retryCount {
          try XCTSkipIf(allowFailure)
          throw Error.retryFailed(attemptCount: attemptCount, error: error)
        } catch _ {
          continue
        }
      }
    }
  }

  override func tearDownWithError() throws {
    try super.tearDownWithError()
    if let index = index {
      try index.delete()
    }
  }

}

extension OnlineTestCase {
  enum Error: Swift.Error {
    case missingCredentials
    case retryFailed(attemptCount: Int, error: Swift.Error)
  }
}
