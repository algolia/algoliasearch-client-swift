//
//  HostSwitcherTests.swift
//  
//
//  Created by Vladislav Fitc on 03/04/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class HostSwitcherTests: XCTestCase {

  func testSwitchHost() throws {
    let method = HTTPMethod.post
    let path = TestPath.path
    let timeout: TimeInterval = 10
    let request = URLRequest(method: method, path: path)

    for index in 0...20 {
      var host = RetryableHost(url: URL(string: "test\(index).algolia.com")!)
      host.retryCount = index
      let requestWithHost = try HostSwitcher.switchHost(in: request, by: host, timeout: timeout)
      XCTAssertEqual(requestWithHost.timeoutInterval, timeout * TimeInterval(index + 1))
      XCTAssertEqual(requestWithHost.url?.absoluteString, "https://test\(index).algolia.com/my/test/path")
    }

  }

}
