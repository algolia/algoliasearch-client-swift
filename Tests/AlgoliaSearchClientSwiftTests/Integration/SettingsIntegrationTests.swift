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

  func testSetGetSettings() throws {

    var settings = Settings()
    settings.attributesForFaceting = [.filterOnly("attr1"), .default("attr2"), .searchable("attr3")]

    let task = try index.setSettings(settings)
    _ = try task.wait()
    let fetchedSettings = try index.getSettings()
    XCTAssertEqual(fetchedSettings.attributesForFaceting, [.filterOnly("attr1"), .default("attr2"), .searchable("attr3")])
  }

}
