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

  func testEncoding() throws {
    try testEncoding(IgnorePlurals.true, expected: true)
    try testEncoding(IgnorePlurals.false, expected: false)
    try testEncoding(IgnorePlurals.queryLanguages([.english, .polish, .french]), expected: [Language.english, Language.polish, Language.french].map(\.rawValue))
  }

  func testDecoding() throws {
    try testDecoding(true, expected: IgnorePlurals.true)
    try testDecoding(false, expected: IgnorePlurals.false)
    try testDecoding([Language.english, Language.polish, Language.french].map { $0.rawValue }, expected: IgnorePlurals.queryLanguages([.english, .polish, .french]))
  }

}
