//
//  AdvancedCommandTests.swift
//  
//
//  Created by Vladislav Fitc on 26/03/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class AdvancedCommandTests: XCTestCase, AlgoliaCommandTest {
  
  func testTaskStatus() {
    let command = Command.Advanced.TaskStatus(indexName: test.indexName, taskID: test.taskID, requestOptions: test.requestOptions)
    check(command: command,
          callType: .read,
          method: .get,
          urlPath: "/1/indexes/testIndex/task/testTaskID",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: nil,
          requestOptions: test.requestOptions)
  }
  
}

