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
  
  let retryableError = URLError(.networkConnectionLost)
  let timeoutError = URLError(.timedOut)
  
  func testHostsRotation() {
    
    let host1 = RetryableHost(url: URL(string: "algolia1.com")!, callType: .write)
    let host2 = RetryableHost(url: URL(string: "algolia2.com")!, callType: .write)
    let host3 = RetryableHost(url: URL(string: "algolia3.com")!, callType: .read)
    let host4 = RetryableHost(url: URL(string: "algolia4.com")!, callType: .read)
    let host5 = RetryableHost(url: URL(string: "algolia5.com")!, callType: .read)
    

    var strategy = AlgoliaRetryStrategy(hosts: [host1, host2, host3, host4, host5])
    
    debugPrint(strategy)
    
    XCTAssertEqual(strategy.host(for: .write)?.url.absoluteString, "algolia1.com")
    XCTAssertEqual(strategy.host(for: .read)?.url.absoluteString, "algolia3.com")
    
    debugPrint(strategy)


    try! strategy.notify(host: host1, result: Result<String, Error>.failure(retryableError))
    
    XCTAssertEqual(strategy.host(for: .write)?.url.absoluteString, "algolia2.com")
    
    try! strategy.notify(host: host2, result: Result<String, Error>.failure(retryableError))
    
    XCTAssertEqual(strategy.host(for: .write)?.url.absoluteString, "algolia1.com")
    
    


    
  }
  
}
