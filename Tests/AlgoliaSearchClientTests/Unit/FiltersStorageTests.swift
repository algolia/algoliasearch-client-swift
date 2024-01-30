//
//  FiltersStorageTests.swift
//
//
//  Created by Vladislav Fitc on 08/07/2020.
//

import Foundation
import XCTest

@testable import AlgoliaSearchClient

class FiltersStorageTests: XCTestCase {
  func testRawConversion() {
    let filtersStorage: FiltersStorage = [
      .and("val1", "val2", "val3"),
      .or("val4", "val5"),
      "val6",
    ]
    XCTAssertEqual(
      filtersStorage.rawValue,
      [
        .single("val1"),
        .single("val2"),
        .single("val3"),
        .list(["val4", "val5"]),
        .single("val6"),
      ])
  }

  func testInitWithRaw() {
    let rawValue: FiltersStorage.RawValue = [
      .single("val1"),
      .list(["val2", "val3", "val4"]),
      .single("val5"),
      .single("val6"),
    ]
    let filtersStorage = FiltersStorage(rawValue: rawValue)
    XCTAssertEqual(
      filtersStorage.units,
      [
        .and("val1"),
        .or("val2", "val3", "val4"),
        .and("val5"),
        .and("val6"),
      ])
  }

  func testCoding() throws {
    let filtersStorage: FiltersStorage = [
      .and("val1", "val2", "val3"),
      .or("val4", "val5"),
      "val6",
    ]
    try AssertEncodeDecode(
      filtersStorage,
      [
        "val1",
        "val2",
        "val3",
        ["val4", "val5"],
        "val6",
      ])
  }
}
