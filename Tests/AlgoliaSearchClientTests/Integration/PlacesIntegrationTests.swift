//
//  PlacesIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 12/04/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class PlacesIntegrationTests: XCTestCase {

  var placesClient: PlacesClient!
  
  let geolocation: Point = .init(latitude: 48.8566, longitude: 2.3522)
  let objectID: ObjectID = "9d43bbad834440abd315bfaa31388bb6"
  let language: Language = .english
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    
    let fetchedCredentials = Result(catching: { try TestCredentials(environment: .places) }).mapError { XCTSkip("\($0)") }
    let credentials = try fetchedCredentials.get()
    placesClient = .init(appID: credentials.applicationID, apiKey: credentials.apiKey)
  }

  func testSearchMultilanguage() throws {
    _ = try placesClient.search(query: "")
  }

  func testSearch() throws {
    _ = try placesClient.search(query: "", language: language)
  }

  func testGetObject() throws {
    _ = try placesClient.getObject(withID: objectID)
  }

  func testReverseGeocodingMultilanguage() throws {
    _ = try placesClient.reverseGeocoding(geolocation: geolocation)
  }

  func testReverseGeocoding() throws {
    _ = try placesClient.reverseGeocoding(geolocation: geolocation, language: language)
  }

}
