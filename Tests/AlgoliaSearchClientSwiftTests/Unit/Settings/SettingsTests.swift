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
    print(settings)
  }

  func testDecoding() throws {
    let data = try Data(filename: "Settings.json")
    let decoder = JSONDecoder()
    _ = try decoder.decode(Settings.self, from: data)
  }
}
