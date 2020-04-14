//
//  PlacesIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 12/04/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class PlacesIntegrationTests: XCTestCase {
  
  var client: PlacesClient!
  let geolocation: Point = .init(latitude: 48.8566, longitude: 2.3522)
  let objectID: ObjectID = "9d43bbad834440abd315bfaa31388bb6"
  let language: Language = .english
  
  override func setUpWithError() throws {
    guard let credentials = TestCredentials.places else {
      throw OnlineTestCase.Error.missingCredentials
    }
    client = PlacesClient(appID: credentials.applicationID, apiKey: credentials.apiKey)
  }

  func testSearchMultilanguage() throws {
    let _ = try client.search(query: "")
  }
  
  func testSearch() throws {
    let _ = try client.search(query: "", language: language)
  }
  
  func testGetObject() throws {
    let _ = try client.getObject(withID: objectID)
  }
  
  func testReverseGeocodingMultilanguage() throws {
    let _ = try client.reverseGeocoding(geolocation: geolocation)
  }
  
  func testReverseGeocoding() throws {
    let _ = try client.reverseGeocoding(geolocation: geolocation, language: language)
  }


}
