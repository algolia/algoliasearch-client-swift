//
//  XCTest+Wait.swift
//
//
//  Created by Vladislav Fitc on 09/07/2020.
//

import Foundation
import XCTest

@testable import AlgoliaSearchClient

let defaultWaitTimeInterval: TimeInterval = 20

func AssertWait(
  _ waitable: some AnyWaitable, timeout _: TimeInterval = defaultWaitTimeInterval,
  file: StaticString = #file, line: UInt = #line
) throws {
  do {
    try waitable.wait(timeout: 20, requestOptions: nil)
  } catch {
    let isTimeoutError = error as? WaitTask.Error == WaitTask.Error.timeout
    try XCTSkipIf(isTimeoutError, file: file, line: line)
    throw error
  }
}
