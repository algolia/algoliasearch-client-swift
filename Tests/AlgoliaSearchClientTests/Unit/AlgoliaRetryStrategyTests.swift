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
    
    let writeHosts = strategy.retryableHosts(for: .write)
    let readHosts = strategy.retryableHosts(for: .read)
    
    // Fresh state, first read and write hosts are available
    XCTAssertEqual(writeHosts.next()?.url.absoluteString, "algolia1.com")
    XCTAssertEqual(readHosts.next()?.url.absoluteString, "algolia3.com")

    // First write host failed
    XCTAssertNoThrow(strategy.notify(host: host1, result: retryableErrorResult))
    // Second write host is available now
    XCTAssertEqual(writeHosts.next()?.url.absoluteString, "algolia2.com")
    // First read host is still available
    XCTAssertEqual(readHosts.next()?.url.absoluteString, "algolia3.com")

    // Second write host failed
    _ = strategy.notify(host: host2, result: retryableErrorResult)
    // No more writable hosts available
    XCTAssertEqual(writeHosts.next()?.url.absoluteString, nil)
    // First read host is still available
    XCTAssertEqual(readHosts.next()?.url.absoluteString, "algolia3.com")

    // First read host failed
    _ = strategy.notify(host: host3, result: retryableErrorResult)
    // No more writable hosts available
    XCTAssertEqual(writeHosts.next()?.url.absoluteString, nil)
    // Second read host is available
    XCTAssertEqual(readHosts.next()?.url.absoluteString, "algolia4.com")

    // Second read host failed
    _ = strategy.notify(host: host4, result: retryableErrorResult)
    // No more writable hosts available
    XCTAssertEqual(writeHosts.next()?.url.absoluteString, nil)
    // Third read host is available
    XCTAssertEqual(readHosts.next()?.url.absoluteString, "algolia5.com")

    // Third read host failed
    _ = strategy.notify(host: host5, result: retryableErrorResult)
    // No more writable hosts available
    XCTAssertEqual(writeHosts.next()?.url.absoluteString, nil)
    // No more writable hosts available
    XCTAssertEqual(readHosts.next()?.url.absoluteString, nil)
    
    // When got new write hosts, all the write hosts reseted
    let newWriteHosts = strategy.retryableHosts(for: .write)
    XCTAssertEqual(newWriteHosts.next()?.url.absoluteString, "algolia1.com")
    
    // Previous write iterator is updated as well as it uses the weak reference to the same retry strategy
    XCTAssertEqual(writeHosts.next()?.url.absoluteString, "algolia1.com")
    
    // Still no read host available
    XCTAssertEqual(readHosts.next()?.url.absoluteString, nil)

    
    // When got new read hosts, all the read hosts reseted
    let newReadHosts = strategy.retryableHosts(for: .read)
    XCTAssertEqual(newReadHosts.next()?.url.absoluteString, "algolia3.com")

    // Previous read iterator is updated as well as it uses the weak reference to the same retry strategy
    XCTAssertEqual(readHosts.next()?.url.absoluteString, "algolia3.com")
    
    // Same state kept for write hosts iterators
    XCTAssertEqual(writeHosts.next()?.url.absoluteString, "algolia1.com")
    XCTAssertEqual(newWriteHosts.next()?.url.absoluteString, "algolia1.com")


  }

  func testTimeout() {

    let strategy = AlgoliaRetryStrategy(hosts: [host3, host4, host5])
    let readHosts = strategy.retryableHosts(for: .read)
    
    var host: RetryableHost?
    var lastUpdate: Date? = readHosts.next()?.lastUpdated

    _ = strategy.notify(host: host3, result: timeoutErrorResult)
    host = readHosts.next()
    XCTAssertGreaterThan(host!.lastUpdated.timeIntervalSince1970, lastUpdate!.timeIntervalSince1970)
    lastUpdate = host?.lastUpdated
    XCTAssertNotNil(host)
    XCTAssertTrue(host!.isUp)
    XCTAssertEqual(host!.retryCount, 1)

    _ = strategy.notify(host: host3, result: timeoutErrorResult)
    host = readHosts.next()
    XCTAssertGreaterThan(host!.lastUpdated.timeIntervalSince1970, lastUpdate!.timeIntervalSince1970)
    XCTAssertNotNil(host)
    XCTAssertTrue(host!.isUp)
    XCTAssertEqual(host!.retryCount, 2)

  }

  func testResetExpired() {
    let expirationDelay: TimeInterval = 3
    let strategy = AlgoliaRetryStrategy(hosts: [host3, host4, host5], hostsExpirationDelay: expirationDelay)
    _ = strategy.retryableHosts(for: .read)
    
    _ = strategy.notify(host: host3, result: retryableErrorResult)
    _ = strategy.notify(host: host4, result: retryableErrorResult)
    _ = strategy.notify(host: host5, result: retryableErrorResult)

    sleep(UInt32(expirationDelay))
    
    let newReadHosts = strategy.retryableHosts(for: .read)

    XCTAssertEqual(newReadHosts.next()?.url.absoluteString, "algolia3.com")
  }

}
