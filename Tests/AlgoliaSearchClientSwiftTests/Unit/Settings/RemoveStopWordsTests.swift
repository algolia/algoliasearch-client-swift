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

  func testEncoding() throws {
    try testEncoding(RemoveStopWords.true, expected: true)
    try testEncoding(RemoveStopWords.false, expected: false)
    try testEncoding(RemoveStopWords.queryLanguages([.english, .polish, .french]), expected: [Language.english, Language.polish, Language.french].map(\.rawValue))
  }

  func testDecoding() throws {
    try testDecoding(true, expected: RemoveStopWords.true)
    try testDecoding(false, expected: RemoveStopWords.false)
    try testDecoding([Language.english, Language.polish, Language.french].map { $0.rawValue }, expected: RemoveStopWords.queryLanguages([.english, .polish, .french]))
  }

}
