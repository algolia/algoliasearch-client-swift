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
    strategy.notify(host: host1, result: retryableErrorResult)
    // Second write host is available now
    XCTAssertEqual(writeHosts.next()?.url.absoluteString, "algolia2.com")
    // First read host is still available
    XCTAssertEqual(readHosts.next()?.url.absoluteString, "algolia3.com")

    // Second write host failed
    strategy.notify(host: host2, result: retryableErrorResult)
    // No more writable hosts available
    XCTAssertEqual(writeHosts.next()?.url.absoluteString, nil)
    // First read host is still available
    XCTAssertEqual(readHosts.next()?.url.absoluteString, "algolia3.com")

    // First read host failed
    strategy.notify(host: host3, result: retryableErrorResult)
    // No more writable hosts available
    XCTAssertEqual(writeHosts.next()?.url.absoluteString, nil)
    // Second read host is available
    XCTAssertEqual(readHosts.next()?.url.absoluteString, "algolia4.com")

    // Second read host failed
    strategy.notify(host: host4, result: retryableErrorResult)
    // No more writable hosts available
    XCTAssertEqual(writeHosts.next()?.url.absoluteString, nil)
    // Third read host is available
    XCTAssertEqual(readHosts.next()?.url.absoluteString, "algolia5.com")

    // Third read host failed
    strategy.notify(host: host5, result: retryableErrorResult)
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

    strategy.notify(host: host3, result: timeoutErrorResult)
    host = readHosts.next()
    XCTAssertGreaterThan(host!.lastUpdated.timeIntervalSince1970, lastUpdate!.timeIntervalSince1970)
    lastUpdate = host?.lastUpdated
    XCTAssertNotNil(host)
    XCTAssertTrue(host!.isUp)
    XCTAssertEqual(host!.retryCount, 1)

    strategy.notify(host: host3, result: timeoutErrorResult)
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
    
    strategy.notify(host: host3, result: retryableErrorResult)
    strategy.notify(host: host4, result: retryableErrorResult)
    strategy.notify(host: host5, result: retryableErrorResult)

    sleep(UInt32(expirationDelay))
    
    let newReadHosts = strategy.retryableHosts(for: .read)

    XCTAssertEqual(newReadHosts.next()?.url.absoluteString, "algolia3.com")
  }
  
  /// Load test of hosts retry strategy
  func testLoad() throws {
    throw XCTSkip()
    
    let expirationDelay: TimeInterval = 3
    let strategy = AlgoliaRetryStrategy(hosts: [host3, host4, host5], hostsExpirationDelay: expirationDelay)

    let queueCount = 100
    // Generate `queueCount` queues with associated count of operation for each
    let queuesWithOpCount = (1...queueCount)
      .map { (queue: DispatchQueue(label: "queue\($0)"), operationCount: Int.random(in: 100...1000)) }
    
    let operationQueue = OperationQueue()
    operationQueue.maxConcurrentOperationCount = 50
    
    // Expectation of completion of all the operations from all the queues
    let allOperationsFinishedExpectation = expectation(description: "All operations finished")
    allOperationsFinishedExpectation.expectedFulfillmentCount = queuesWithOpCount.map(\.operationCount).reduce(0, +)
    
    // Launch `operationCount` operation from each queue with randomized launch delay
    for (queue, operationCount) in queuesWithOpCount {
      for count in 1...operationCount {
        queue.asyncAfter(deadline: .now() + .milliseconds(.random(in: 10...500))) {
          let callType: CallType = [.read, .write].randomElement()!
          let operation = RetryableOperation(retryStrategy: strategy, callType: callType)
          operation.name = "\(queue.label) - \(count)"
          operation.completionBlock = {
            allOperationsFinishedExpectation.fulfill()
          }
          operationQueue.addOperation(operation)
        }
      }
    }

    waitForExpectations(timeout: 20, handler: nil)
  }

}

/// Operation imitating server responses for the purpose of testing the retry strategy
class RetryableOperation: Operation {
  
  let retryStrategy: RetryStrategy
  let callType: CallType
  let waitQueue = DispatchQueue(label: "internal")

  init(retryStrategy: RetryStrategy, callType: CallType) {
    self.retryStrategy = retryStrategy
    self.callType = callType
    super.init()
  }
  
  override var debugDescription: String {
    return "\(name ?? "")"
  }
  
  override func main() {
    let hostsIterator = retryStrategy.retryableHosts(for: callType)
    
    while let host = hostsIterator.next() {
      let result = getResult()
      retryStrategy.notify(host: host, result: result)
      if case .failure(let error) = result, retryStrategy.canRetry(inCaseOf: error) {
        continue
      } else {
        break
      }
    }
  }
  
  func getResult() -> Result<String, Error> {
    return [
      .failure(HTTPError(statusCode: .requestTimeout, message: nil)),
      .failure(URLError(.badServerResponse)),
      .failure(InternalError()),
      .success("")
    ].randomElement()!
  }
  
  struct InternalError: Error {}
  
}
