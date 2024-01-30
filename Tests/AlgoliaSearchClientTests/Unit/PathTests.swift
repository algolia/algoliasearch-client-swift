//
//  File.swift
//
//
//  Created by Vladislav Fitc on 05/04/2020.
//

import Foundation
import XCTest

@testable import AlgoliaSearchClient

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

class PathTests: XCTestCase {
  func testIndexNameEncoding() {
    let path = URL(string: "/1/indexes/")!.appendingPathComponent(
      "Index name with spaces".addingPercentEncoding(
        withAllowedCharacters: .urlPathComponentAllowed)!)
    let request = URLRequest(
      command: Command.Custom(
        method: .post, callType: .write, path: path, body: nil, requestOptions: nil))
    XCTAssertEqual(
      request.url?.absoluteString.starts(with: "https:/1/indexes/Index%20name%20with%20spaces"),
      true)
  }
}
