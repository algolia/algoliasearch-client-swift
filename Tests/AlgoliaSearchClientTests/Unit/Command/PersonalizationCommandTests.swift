//
//  PersonalizationCommandTests.swift
//  
//
//  Created by Vladislav Fitc on 27/05/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class PersonalizationCommandTests: XCTestCase, AlgoliaCommandTest {
  
  func testGet() {
    let command = Command.Personalization.Get(requestOptions: test.requestOptions)
    check(command: command,
          callType: .read,
          method: .get,
          urlPath: "/1/strategies/personalization",
          queryItems: [
              .init(name: "testParameter", value: "testParameterValue"),
          ],
          body: nil,
          requestOptions: test.requestOptions)
  }
  
  func testSet() {
    let command = Command.Personalization.Set(strategy: test.personalizationStrategy, requestOptions: test.requestOptions)
    check(command: command,
          callType: .write,
          method: .post,
          urlPath: "/1/strategies/personalization",
          queryItems: [
              .init(name: "testParameter", value: "testParameterValue"),
          ],
          body: test.personalizationStrategy.httpBody,
          additionalHeaders: ["Content-Type": "application/json"],
          requestOptions: test.requestOptions)
  }
  
}
