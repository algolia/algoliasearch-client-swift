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

  func testGetLogs() {
    let command = Command.Advanced.GetLogs(indexName: test.indexName, page: 10, hitsPerPage: 100, logType: .all, requestOptions: test.requestOptions)
    check(command: command,
          callType: .read,
          method: .get,
          urlPath: "/1/logs",
          queryItems: [.init(name: "testParameter", value: "testParameterValue"),
                       .init(name: HTTPParameterKey.indexName.rawValue, value: "testIndex"),
                       .init(name: HTTPParameterKey.offset.rawValue, value: "10"),
                       .init(name: HTTPParameterKey.length.rawValue, value: "100"),
                       .init(name: HTTPParameterKey.type.rawValue, value: "all")
                      ],
          body: nil,
          requestOptions: test.requestOptions
            .settingParameter("testIndex", forKey: .indexName)
            .settingParameter("10", forKey: .offset)
            .settingParameter("100", forKey: .length)
            .settingParameter("all", forKey: .type))
  }

}
