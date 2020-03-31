//
//  DecompoundedAttributesTests.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class DecompoundedAttributesTests: XCTestCase {

  func testCoding() throws {
    try AssertEncodeDecode(DecompoundedAttributes((.german, ["attr1", "attr2", "attr3"])), ["de": ["attr1", "attr2", "attr3"]])

  }

}
