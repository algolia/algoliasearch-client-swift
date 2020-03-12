//
//  SettingsTests.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class SettingsTests: XCTestCase {
  
  func testHome() {
    var settings = Settings()
    settings.attributesForFaceting = [.default("attr1"), .filterOnly("attr2"), .searchable("attr3")]
    settings.sortFacetsBy = .count
    settings.attributesToHighlight = ["attr2", "attr3"]
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try! encoder.encode(settings)
    let string = String(data: data, encoding: .utf8)!
    print(string)
  }
  
}
