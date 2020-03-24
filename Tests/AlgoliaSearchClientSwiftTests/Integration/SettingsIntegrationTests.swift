//
//  SettingsIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 05/03/2020.
//

import Foundation

import XCTest
@testable import AlgoliaSearchClientSwift

class SettingsIntegrationTests: OnlineTestCase {

  func testSetGetSettings() {

    var settings = Settings()
    settings.attributesForFaceting = [.filterOnly("attr1"), .default("attr2"), .searchable("attr3")]

    do {
      let task = try index.setSettings(settings)
      _ = try index.wait(for: task)
      let settings = try index.getSettings()
      XCTAssertEqual(settings.attributesForFaceting, [.filterOnly("attr1"), .default("attr2"), .searchable("attr3")])
    } catch let error {
      XCTFail("\(error)")
    }

  }

}
