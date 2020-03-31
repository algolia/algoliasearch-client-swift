//
//  IgnorePluralsTests.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class IgnorePluralsTests: XCTestCase {

  func testCoding() throws {
    try AssertEncodeDecode(IgnorePlurals.true, true)
    try AssertEncodeDecode(IgnorePlurals.false, false)
    try AssertEncodeDecode(IgnorePlurals.queryLanguages([.english, .polish, .french]), [.init(Language.english.rawValue), .init(Language.polish.rawValue), .init(Language.french.rawValue)])
  }

}
