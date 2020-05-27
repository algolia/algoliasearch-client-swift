//
//  Personalization.swift
//  
//
//  Created by Vladislav Fitc on 27/05/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class PersonalizationIntegrationTests: OnlineTestCase {
  
  func testPersonalization() throws {
    let recommendationClient = RecommendationClient(appID: client.applicationID, apiKey: client.apiKey, region: .custom("eu"))
    let strategy = try recommendationClient.getPersonalizationStrategy()
  }
  
}
