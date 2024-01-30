//
//  TestAssertions.swift
//
//
//  Created by Vladislav Fitc on 20/11/2020.
//

import Foundation
import XCTest

@testable import AlgoliaSearchClient

extension XCTestCase {
  func expectingAssertionFailure(expectedMessage: String, block: () -> Void) {
    let expectation = expectation(description: "failing assertion")

    // Overwrite `assertionFailure` with something that doesn't terminate but verifies it happened.
    assertionClosure = { message, file, line in
      expectation.fulfill()
      XCTAssertEqual(
        message, expectedMessage, "precondition message didn't match", file: file, line: line)
    }

    // Call code.
    block()

    // Verify assertion "failed".
    waitForExpectations(timeout: 10, handler: nil)

    // Reset assertionFailure.
    assertionClosure = defaultAssertionClosure
  }
}
