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
    try AssertEncodeDecode([.german: ["attr1", "attr2", "attr3"]] as DecompoundedAttributes, ["de": ["attr1", "attr2", "attr3"]])
  }

}
