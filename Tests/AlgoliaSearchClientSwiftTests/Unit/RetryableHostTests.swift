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
  
  func testReadTimeoutIncrement() {
    
    var requestOptions = RequestOptions()
    requestOptions.readTimeout = 10
    
    var host = RetryableHost(url: URL(string: "algolia.com")!, callType: .read)

    XCTAssertEqual(host.timeout(), 5, accuracy: 0.1)
    XCTAssertEqual(host.timeout(requestOptions: requestOptions), 10, accuracy: 0.1)
    
    host.hasTimedOut()
    
    XCTAssertEqual(host.timeout(), 10, accuracy: 0.1)
    XCTAssertEqual(host.timeout(requestOptions: requestOptions), 20, accuracy: 0.1)

    host.hasTimedOut()

    XCTAssertEqual(host.timeout(), 15, accuracy: 0.1)
    XCTAssertEqual(host.timeout(requestOptions: requestOptions), 30, accuracy: 0.1)
  }
  
  func testWriteTimeoutIncrement() {
    
    var requestOptions = RequestOptions()
    requestOptions.writeTimeout = 20

    var host = RetryableHost(url: URL(string: "algolia.com")!, callType: .write)
    
    XCTAssertEqual(host.timeout(), 30, accuracy: 0.1)
    XCTAssertEqual(host.timeout(requestOptions: requestOptions), 20, accuracy: 0.1)
    
    host.hasTimedOut()
    
    XCTAssertEqual(host.timeout(), 60, accuracy: 0.1)
    XCTAssertEqual(host.timeout(requestOptions: requestOptions), 40, accuracy: 0.1)

    host.hasTimedOut()

    XCTAssertEqual(host.timeout(), 90, accuracy: 0.1)
    XCTAssertEqual(host.timeout(requestOptions: requestOptions), 60, accuracy: 0.1)


  }
  
}
