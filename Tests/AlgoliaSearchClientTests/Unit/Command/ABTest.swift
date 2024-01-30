//
//  ABTestCommandTest.swift
//
//
//  Created by Vladislav Fitc on 28/05/2020.
//

import Foundation
import XCTest

@testable import AlgoliaSearchClient

class ABTestCommandTest: XCTestCase, AlgoliaCommandTest {
  func testAdd() {
    let command = Command.ABTest.Add(abTest: test.abTest, requestOptions: test.requestOptions)
    check(
      command: command,
      callType: .write,
      method: .post,
      urlPath: "/2/abtests",
      queryItems: [.init(name: "testParameter", value: "testParameterValue")],
      body: test.abTest.httpBody,
      requestOptions: test.requestOptions)
  }

  func testGet() {
    let command = Command.ABTest.Get(abTestID: "testABTestID", requestOptions: test.requestOptions)
    check(
      command: command,
      callType: .read,
      method: .get,
      urlPath: "/2/abtests/testABTestID",
      queryItems: [.init(name: "testParameter", value: "testParameterValue")],
      body: nil,
      requestOptions: test.requestOptions)
  }

  func testStop() {
    let command = Command.ABTest.Stop(abTestID: "testABTestID", requestOptions: test.requestOptions)
    check(
      command: command,
      callType: .write,
      method: .post,
      urlPath: "/2/abtests/testABTestID/stop",
      queryItems: [.init(name: "testParameter", value: "testParameterValue")],
      body: nil,
      requestOptions: test.requestOptions)
  }

  func testDelete() {
    let command = Command.ABTest.Delete(
      abTestID: "testABTestID", requestOptions: test.requestOptions)
    check(
      command: command,
      callType: .write,
      method: .delete,
      urlPath: "/2/abtests/testABTestID",
      queryItems: [.init(name: "testParameter", value: "testParameterValue")],
      body: nil,
      requestOptions: test.requestOptions)
  }

  func testList() {
    let command = Command.ABTest.List(offset: 10, limit: 20, requestOptions: test.requestOptions)
    check(
      command: command,
      callType: .read,
      method: .get,
      urlPath: "/2/abtests",
      queryItems: [
        .init(name: "testParameter", value: "testParameterValue"),
        .init(name: "offset", value: "10"),
        .init(name: "limit", value: "20"),
      ],
      body: nil,
      requestOptions: test.requestOptions)
  }
}
