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

func AssertWait<W: AnyWaitable>(_ waitable: W, timeout: TimeInterval = defaultWaitTimeInterval, file: StaticString = #file, line: UInt = #line) throws {
  do {
    try waitable.wait(timeout: 20, requestOptions: nil)
  } catch let error {
    let isTimeoutError = error as? WaitTask.Error == WaitTask.Error.timeout
    try XCTSkipIf(isTimeoutError, file: file, line: line)
    throw error
  }
}
