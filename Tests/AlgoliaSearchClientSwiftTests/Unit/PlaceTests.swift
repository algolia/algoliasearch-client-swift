//
//  PlaceTests.swift
//  
//
//  Created by Vladislav Fitc on 12/04/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class PlaceTests: XCTestCase {

  func testDecoding() throws {
    let place = try AssertDecode(jsonFilename: "Place.json", expected: Place.self)
    XCTAssertEqual(place.country, "Denmark")
    XCTAssertEqual(place.isCountry, false)
    XCTAssertEqual(place.isHighway, false)
    XCTAssertEqual(place.importance, 16)
    XCTAssertEqual(place.tags, ["city", "country/dk", "place/city", "source/geonames"])
    XCTAssertEqual(place.postcode, ["8000"])
    XCTAssertEqual(place.county, ["Aarhus Municipality"])
    XCTAssertEqual(place.population, 256018)
    XCTAssertEqual(place.countryCode, .denmark)
    XCTAssertEqual(place.isCity, true)
    XCTAssertEqual(place.isPopular, true)
    XCTAssertEqual(place.administrative, ["Region Midtjylland"])
    XCTAssertEqual(place.adminLevel, 15)
    XCTAssertEqual(place.isSuburb, false)
    XCTAssertEqual(place.localeNames, ["Aarhus"])
  }

  func testDecodingMultiLanguage() throws {
//    try let place = AssertDecode(jsonFilename: "MultiLanguagePlace.json", expected: Place.self)
  }

}
