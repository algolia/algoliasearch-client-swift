//
//  Personalization.swift
//  
//
//  Created by Vladislav Fitc on 27/05/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class PersonalizationIntegrationTests: IntegrationTestCase {
  
  override var retryableTests: [() throws -> Void] {
    [
     getStrategy,
     setStrategy
    ]
  }

  func getStrategy() throws {
    let recommendationClient = PersonalizationClient(appID: client.applicationID, apiKey: client.apiKey, region: .custom("us"))
    let _ = try recommendationClient.getPersonalizationStrategy()
  }
  
  func setStrategy() throws {
    
    let personalizationClient = PersonalizationClient(appID: client.applicationID, apiKey: client.apiKey, region: .custom("us"))

    let strategy = PersonalizationStrategy(
      eventsScoring: [
        .init(eventName: "Add to cart", eventType: .conversion, score: 50),
        .init(eventName: "Purchase", eventType: .conversion, score: 100)
      ],
      facetsScoring: [
        .init(facetName: "brand", score: 100),
        .init(facetName: "categories", score: 10)
      ],
      personalizationImpact: 0
    )

    do {
      try personalizationClient.setPersonalizationStrategy(strategy)
    } catch .httpError(let httpError) as TransportError where httpError.statusCode == HTTPStatusСode.tooManyRequests {
      // The personalization API is now limiting the number of setPersonalizationStrategy()` successful calls
      // to 15 per day. If the 429 error is returned, the response is considered a "success".
    } catch let error {
      throw error
    }
  }
  
}
