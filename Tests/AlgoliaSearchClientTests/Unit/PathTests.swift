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

  func testPath() {
    XCTAssertEqual(Path.indexesV1.fullPath, "/1/indexes")
    XCTAssertEqual((.indexesV1 >>> IndexRoute.index("testIndex")).fullPath, "/1/indexes/testIndex")
    XCTAssertEqual((.indexesV1 >>> .index("testIndex") >>> IndexCompletion.batch).fullPath, "/1/indexes/testIndex/batch")
  }
  
  func testIndexNameEncoding() {
    let indexName: IndexName = "Index name with spaces"
    let path = .indexesV1 >>> IndexRoute.index(indexName)
    let request = URLRequest(method: .post, path: path)
    XCTAssertEqual(request.url?.absoluteString, "https:/1/indexes/Index%20name%20with%20spaces")
  }

}
