//
//  AlgoliaRetryStrategyTests.swift
//  
//
//  Created by Vladislav Fitc on 13.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class AlgoliaRetryStrategyTests: XCTestCase {

  let host1 = RetryableHost(url: URL(string: "algolia1.com")!, callType: .write)
  let host2 = RetryableHost(url: URL(string: "algolia2.com")!, callType: .write)
  let host3 = RetryableHost(url: URL(string: "algolia3.com")!, callType: .read)
  let host4 = RetryableHost(url: URL(string: "algolia4.com")!, callType: .read)
  let host5 = RetryableHost(url: URL(string: "algolia5.com")!, callType: .read)

  let successResult = Result<String, Error>.success("success")
  let retryableErrorResult = Result<String, Error>.failure(URLError(.networkConnectionLost))
  let timeoutErrorResult = Result<String, Error>.failure(URLError(.timedOut))

  func testHostsRotation() {

    let strategy = AlgoliaRetryStrategy(hosts: [host1, host2, host3, host4, host5])

    XCTAssertEqual(strategy.host(for: .write)?.url.absoluteString, "algolia1.com")
    XCTAssertEqual(strategy.host(for: .read)?.url.absoluteString, "algolia3.com")

    XCTAssertNoThrow(strategy.notify(host: host1, result: retryableErrorResult))
    XCTAssertEqual(strategy.host(for: .write)?.url.absoluteString, "algolia2.com")
    XCTAssertEqual(strategy.host(for: .read)?.url.absoluteString, "algolia3.com")

    _ = strategy.notify(host: host2, result: retryableErrorResult)
    XCTAssertEqual(strategy.host(for: .write)?.url.absoluteString, "algolia1.com")
    XCTAssertEqual(strategy.host(for: .read)?.url.absoluteString, "algolia3.com")

    _ = strategy.notify(host: host3, result: retryableErrorResult)
    XCTAssertEqual(strategy.host(for: .write)?.url.absoluteString, "algolia1.com")
    XCTAssertEqual(strategy.host(for: .read)?.url.absoluteString, "algolia4.com")

    _ = strategy.notify(host: host4, result: retryableErrorResult)
    XCTAssertEqual(strategy.host(for: .write)?.url.absoluteString, "algolia1.com")
    XCTAssertEqual(strategy.host(for: .read)?.url.absoluteString, "algolia5.com")

    _ = strategy.notify(host: host5, result: retryableErrorResult)
    XCTAssertEqual(strategy.host(for: .write)?.url.absoluteString, "algolia1.com")
    XCTAssertEqual(strategy.host(for: .read)?.url.absoluteString, "algolia3.com")

  }

  func testTimeout() {

    let strategy = AlgoliaRetryStrategy(hosts: [host3, host4, host5])

    var host: RetryableHost?
    var lastUpdate: Date? = strategy.host(for: .read)?.lastUpdated

    _ = strategy.notify(host: host3, result: timeoutErrorResult)
    host = strategy.host(for: .read)
    XCTAssertGreaterThan(host!.lastUpdated.timeIntervalSince1970, lastUpdate!.timeIntervalSince1970)
    lastUpdate = host?.lastUpdated
    XCTAssertNotNil(host)
    XCTAssertTrue(host!.isUp)
    XCTAssertEqual(host!.retryCount, 1)

    _ = strategy.notify(host: host3, result: timeoutErrorResult)
    host = strategy.host(for: .read)
    XCTAssertGreaterThan(host!.lastUpdated.timeIntervalSince1970, lastUpdate!.timeIntervalSince1970)
    XCTAssertNotNil(host)
    XCTAssertTrue(host!.isUp)
    XCTAssertEqual(host!.retryCount, 2)

  }

  func testResetExpired() {
    let expirationDelay: TimeInterval = 3
    let strategy = AlgoliaRetryStrategy(hosts: [host3, host4, host5], hostsExpirationDelay: expirationDelay)

    _ = strategy.notify(host: host3, result: retryableErrorResult)
    _ = strategy.notify(host: host4, result: retryableErrorResult)
    _ = strategy.notify(host: host5, result: retryableErrorResult)

    sleep(UInt32(expirationDelay))

    XCTAssertEqual(strategy.host(for: .read)?.url.absoluteString, "algolia3.com")
  }

}
