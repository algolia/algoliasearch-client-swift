//
//  RetryableHostTests.swift
//  
//
//  Created by Vladislav Fitc on 17/03/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class RetryableHostTests: XCTestCase {

  func testConstruction() {
    let host = RetryableHost(url: URL(string: "algolia.com")!, callType: .read)
    XCTAssertEqual(host.url.absoluteString, "algolia.com")
    XCTAssertTrue(host.isUp)
    XCTAssertEqual(host.supportedCallTypes, .read)
    XCTAssertEqual(host.retryCount, 0)
  }

  func testFail() {
    var host = RetryableHost(url: URL(string: "algolia.com")!, callType: .read)
    let previouslyUpdated = host.lastUpdated
    sleep(1)
    host.hasFailed()
    XCTAssertFalse(host.isUp)
    XCTAssertGreaterThan(host.lastUpdated.timeIntervalSince1970, previouslyUpdated.timeIntervalSince1970)
  }

  func testTimeout() {

    var host = RetryableHost(url: URL(string: "algolia.com")!, callType: .read)
    var previouslyUpdated: Date

    previouslyUpdated = host.lastUpdated
    sleep(1)
    host.hasTimedOut()
    XCTAssertTrue(host.isUp)
    XCTAssertEqual(host.retryCount, 1)
    XCTAssertGreaterThan(host.lastUpdated.timeIntervalSince1970, previouslyUpdated.timeIntervalSince1970)

    previouslyUpdated = host.lastUpdated
    sleep(1)
    host.hasTimedOut()
    XCTAssertTrue(host.isUp)
    XCTAssertEqual(host.retryCount, 2)
    XCTAssertGreaterThan(host.lastUpdated.timeIntervalSince1970, previouslyUpdated.timeIntervalSince1970)

  }

  func testReset() {
    var host = RetryableHost(url: URL(string: "algolia.com")!, callType: .read)
    var previouslyUpdated: Date

    previouslyUpdated = host.lastUpdated
    sleep(1)
    host.hasTimedOut()
    host.hasFailed()
    XCTAssertFalse(host.isUp)
    XCTAssertEqual(host.retryCount, 1)
    XCTAssertGreaterThan(host.lastUpdated.timeIntervalSince1970, previouslyUpdated.timeIntervalSince1970)

    previouslyUpdated = host.lastUpdated
    sleep(1)
    host.reset()
    XCTAssertTrue(host.isUp)
    XCTAssertEqual(host.retryCount, 0)
    XCTAssertGreaterThan(host.lastUpdated.timeIntervalSince1970, previouslyUpdated.timeIntervalSince1970)
  }

//
}
