//
//  LanguageFeatureTests.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class LanguageFeatureTests: XCTestCase {
  
  func testCoding() throws {
    try AssertEncodeDecode(LanguageFeature.true, true)
    try AssertEncodeDecode(LanguageFeature.false, false)
    try AssertEncodeDecode(LanguageFeature.queryLanguages([.english, .polish, .french]), [.init(Language.english.rawValue), .init(Language.polish.rawValue), .init(Language.french.rawValue)])
  }
  
}
