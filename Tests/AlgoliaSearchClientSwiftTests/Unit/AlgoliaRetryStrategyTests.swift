//
//  AlgoliaRetryStrategyTests.swift
//  
//
//  Created by Vladislav Fitc on 13.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

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

    var strategy = AlgoliaRetryStrategy(hosts: [host1, host2, host3, host4, host5])

    XCTAssertEqual(strategy.host(for: .write)?.url.absoluteString, "algolia1.com")
    XCTAssertEqual(strategy.host(for: .read)?.url.absoluteString, "algolia3.com")

    XCTAssertNoThrow(try strategy.notify(host: host1, result: retryableErrorResult))
    XCTAssertEqual(strategy.host(for: .write)?.url.absoluteString, "algolia2.com")
    XCTAssertEqual(strategy.host(for: .read)?.url.absoluteString, "algolia3.com")

    XCTAssertNoThrow(try strategy.notify(host: host2, result: retryableErrorResult))
    XCTAssertEqual(strategy.host(for: .write)?.url.absoluteString, "algolia1.com")
    XCTAssertEqual(strategy.host(for: .read)?.url.absoluteString, "algolia3.com")

    XCTAssertNoThrow(try strategy.notify(host: host3, result: retryableErrorResult))
    XCTAssertEqual(strategy.host(for: .write)?.url.absoluteString, "algolia1.com")
    XCTAssertEqual(strategy.host(for: .read)?.url.absoluteString, "algolia4.com")

    XCTAssertNoThrow(try strategy.notify(host: host4, result: retryableErrorResult))
    XCTAssertEqual(strategy.host(for: .write)?.url.absoluteString, "algolia1.com")
    XCTAssertEqual(strategy.host(for: .read)?.url.absoluteString, "algolia5.com")

    XCTAssertNoThrow(try strategy.notify(host: host5, result: retryableErrorResult))
    XCTAssertEqual(strategy.host(for: .write)?.url.absoluteString, "algolia1.com")
    XCTAssertEqual(strategy.host(for: .read)?.url.absoluteString, "algolia3.com")

  }

  func testTimeout() {

    var strategy = AlgoliaRetryStrategy(hosts: [host3, host4, host5])

    var host: RetryableHost?
    var lastUpdate: Date? = strategy.host(for: .read)?.lastUpdated

    XCTAssertNoThrow(try strategy.notify(host: host3, result: timeoutErrorResult))
    host = strategy.host(for: .read)
    XCTAssertGreaterThan(host!.lastUpdated.timeIntervalSince1970, lastUpdate!.timeIntervalSince1970)
    lastUpdate = host?.lastUpdated
    XCTAssertNotNil(host)
    XCTAssertTrue(host!.isUp)
    XCTAssertEqual(host!.retryCount, 1)

    XCTAssertNoThrow(try strategy.notify(host: host3, result: timeoutErrorResult))
    host = strategy.host(for: .read)
    XCTAssertGreaterThan(host!.lastUpdated.timeIntervalSince1970, lastUpdate!.timeIntervalSince1970)
    XCTAssertNotNil(host)
    XCTAssertTrue(host!.isUp)
    XCTAssertEqual(host!.retryCount, 2)

  }

  func testResetExpired() {
    let expirationDelay: TimeInterval = 3
    var strategy = AlgoliaRetryStrategy(hosts: [host3, host4, host5], hostsExpirationDelay: expirationDelay)

    XCTAssertNoThrow(try strategy.notify(host: host3, result: retryableErrorResult))
    XCTAssertNoThrow(try strategy.notify(host: host4, result: retryableErrorResult))
    XCTAssertNoThrow(try strategy.notify(host: host5, result: retryableErrorResult))

    sleep(UInt32(expirationDelay))

    XCTAssertEqual(strategy.host(for: .read)?.url.absoluteString, "algolia3.com")
  }

}
