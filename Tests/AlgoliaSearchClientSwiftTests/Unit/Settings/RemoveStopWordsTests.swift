//
//  RemoveStopWordsTests.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class RemoveStopWordsTests: XCTestCase {

  func testEncoding() {
    testEncoding(RemoveStopWords.true, expected: true)
    testEncoding(RemoveStopWords.false, expected: false)
    testEncoding(RemoveStopWords.queryLanguages([.english, .polish, .french]), expected: [Language.english, Language.polish, Language.french].map { $0.rawValue })
  }
  
  func testDecoding() {
    testDecoding(true, expected: RemoveStopWords.true)
    testDecoding(false, expected: RemoveStopWords.false)
    testDecoding([Language.english, Language.polish, Language.french].map { $0.rawValue }, expected: RemoveStopWords.queryLanguages([.english, .polish, .french]))
  }
  
}
