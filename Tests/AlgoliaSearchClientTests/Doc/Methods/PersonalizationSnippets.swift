//
//  PersonalizationSnippets.swift
//  
//
//  Created by Vladislav Fitc on 01/07/2020.
//

import Foundation
import AlgoliaSearchClient

struct PersonalizationSnippets: SnippetsCollection {
  
  let recommendationClient = RecommendationClient(appID: "", apiKey: "")
}

//MARK: - Set region
extension PersonalizationSnippets {
  
  func personalization_region() {
    let recommendationClient = RecommendationClient(
      appID: "YourApplicationID",
      apiKey: "YourAdminAPIKey",
      region: .init(rawValue: "eu") // defaults to 'us'
    )
    
    recommendationClient.getPersonalizationStrategy { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Add strategy
extension PersonalizationSnippets {
  
  static var addStrategy = """
  recommendationClient.setPersonalizationStrategy(
    _ ${strategy}: __PersonalizationStrategy__,
    ${requestOptions}: __RequestOptions?__ = nil,
    completion: __Result<SetStrategyResponse> -> Void__
  )
  """
  
  func addStrategy() {
    let recommendationClient = RecommendationClient(appID: "YourApplicationID", apiKey: "YourAPIKey")
    
    let eventsScoring: [EventScoring] = [
      .init(eventName: "Add to cart", eventType: .conversion, score: 50),
      .init(eventName: "Purchase", eventType: .conversion, score: 100)
    ]
    
    let facetsScoring: [FacetScoring] = [
      .init(facetName: "brand", score: 100),
      .init(facetName: "categories", score: 10)
    ]
    
    let strategy = PersonalizationStrategy(eventsScoring: eventsScoring,
                                           facetsScoring: facetsScoring,
                                           personalizationImpact: 0)
    
    recommendationClient.setPersonalizationStrategy(strategy) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Get strategy
extension PersonalizationSnippets {
  
  static var getStrategy = """
  recommendationClient.getPersonalizationStrategy(
    ${requestOptions}: __RequestOptions?__ = nil,
    completion:  __Result<PersonalizationStrategy> -> Void__
  )
  """
  
  func getStrategy() {
    recommendationClient.getPersonalizationStrategy { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

