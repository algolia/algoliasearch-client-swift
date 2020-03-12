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

  func testEncoding() {
    testEncoding(IgnorePlurals.true, expected: true)
    testEncoding(IgnorePlurals.false, expected: false)
    testEncoding(IgnorePlurals.queryLanguages([.english, .polish, .french]), expected: [Language.english, Language.polish, Language.french].map { $0.rawValue })
  }
  
  func testDecoding() {
    testDecoding(true, expected: IgnorePlurals.true)
    testDecoding(false, expected: IgnorePlurals.false)
    testDecoding([Language.english, Language.polish, Language.french].map { $0.rawValue }, expected: IgnorePlurals.queryLanguages([.english, .polish, .french]))
  }
  
}
