//
//  SettingsCommandTests.swift
//  
//
//  Created by Vladislav Fitc on 26/03/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class SettingsCommandTests: XCTestCase, AlgoliaCommandTest {
  
  func testGetSettings() {
    let command = Command.Settings.GetSettings(indexName: test.indexName, requestOptions: test.requestOptions)
    check(command: command,
          callType: .read,
          method: .get,
          urlPath: "/1/indexes/testIndex/settings",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: nil,
          requestOptions: test.requestOptions)
  }
  
  func testSetSettings() {
    let command = Command.Settings.SetSettings(indexName: test.indexName, settings: test.settings, resetToDefault: [.attributesToSnippet], forwardToReplicas: false, requestOptions: test.requestOptions)
    check(command: command,
          callType: .write,
          method: .put,
          urlPath: "/1/indexes/testIndex/settings",
          queryItems: [.init(name: "testParameter", value: "testParameterValue"), .init(name: "forwardToReplicas", value: "false")],
          body: test.settings.httpBody,
          requestOptions: test.requestOptions)
  }
  
}
