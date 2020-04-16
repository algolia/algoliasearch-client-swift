//
//  File.swift
//  
//
//  Created by Vladislav Fitc on 05/04/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class PathTests: XCTestCase {

  func testPath() {
    XCTAssertEqual(Path.indexesV1.fullPath, "/1/indexes")
    XCTAssertEqual((.indexesV1 >>> IndexRoute.index("testIndex")).fullPath, "/1/indexes/testIndex")
    XCTAssertEqual((.indexesV1 >>> .index("testIndex") >>> IndexCompletion.batch).fullPath, "/1/indexes/testIndex/batch")
  }

}
