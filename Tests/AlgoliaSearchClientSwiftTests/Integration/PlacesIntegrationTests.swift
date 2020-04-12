//
//  PlacesIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 12/04/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class PlacesIntegrationTests: OnlineTestCase {

  func testSearch() throws {
    
    guard let credentials = TestCredentials.places else {
      throw Error.missingCredentials
    }
    
    let placesClient = PlacesClient(appID: credentials.applicationID, apiKey: credentials.apiKey)
    
    let result = try placesClient.search(query: "")
    
    print(result)
    
    
  }

}
