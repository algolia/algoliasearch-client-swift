//
//  DetectingIntentSnippets.swift
//  
//
//  Created by Vladislav Fitc on 25/08/2020.
//

import Foundation
import AlgoliaSearchClient

struct DetectingIntentSnippets: SnippetsCollection {
  

}

//MARK: - Applying a custom filter for a specific query

extension DetectingIntentSnippets {
  
  func api_faceting_negative_example() {
    let settings = Settings()
      .set(\.attributesForFaceting, to: ["allergens"])
    
    index.setSettings(settings) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func api_save_rule_negative_example() {
    let rule = Rule(objectID: "gluten-free-rule")
      .set(\.conditions, to: [
        Rule.Condition()
          .set(\.anchoring, to: .contains)
          .set(\.pattern, to: .literal("gluten-free"))
      ])
      .set(\.consequence, to: Rule.Consequence()
        .set(\.queryTextAlteration, to: .edits([.remove("gluten-free")]))
        .set(\.query, to: Query().set(\.filters, to: "NOT allergens:gluten"))
      )
    
    index.saveRule(rule) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func api_save_rule_positive_example() {
    let rule = Rule(objectID: "diet-rule")
      .set(\.conditions, to: [
        Rule.Condition()
          .set(\.anchoring, to: .contains)
          .set(\.pattern, to: .literal("diet"))
      ])
      .set(\.consequence, to: Rule.Consequence()
        .set(\.queryTextAlteration, to: .edits([.remove("diet")]))
        .set(\.query, to: Query().set(\.filters, to: "\"low-carb\" OR \"low-fat\""))
      )
    
    index.saveRule(rule) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func api_save_rule_optional_example() {
    let rule = Rule(objectID: "asap-rule")
      .set(\.conditions, to: [
        Rule.Condition()
          .set(\.anchoring, to: .contains)
          .set(\.pattern, to: .literal("asap"))
      ])
      .set(\.consequence, to: Rule.Consequence()
        .set(\.queryTextAlteration, to: .edits([.remove("asap")]))
        .set(\.query, to: Query().set(\.optionalFilters, to: ["can_deliver_quickly:true"]))
      )
    
    index.saveRule(rule) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Adding search parameters dynamically

extension DetectingIntentSnippets {
  
  func api_settings_example() {
    let settings = Settings()
      .set(\.customRanking, to: [.desc("nb_airline_liaisons")])
      .set(\.attributesForFaceting, to: ["city", "country"])
    
    index.setSettings(settings) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func api_rules_example() {
    let rules: [Rule] = [
      Rule(objectID: "country")
        .set(\.conditions, to: [
          Rule.Condition()
            .set(\.anchoring, to: .contains)
            .set(\.pattern, to: .facet("country"))
        ])
        .set(\.consequence, to: Rule.Consequence()
          .set(\.query, to: Query()
            .set(\.aroundLatLngViaIP, to: false)
          )
        ),
      Rule(objectID: "country")
        .set(\.conditions, to: [
          Rule.Condition()
            .set(\.anchoring, to: .contains)
            .set(\.pattern, to: .facet("city"))
        ])
        .set(\.consequence, to: Rule.Consequence()
          .set(\.query, to: Query()
            .set(\.aroundLatLngViaIP, to: false)
          )
        )
    ]
    
    index.saveRules(rules) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func api_query_example() {
    let query = Query()
      .set(\.query, to: "query")
      .set(\.aroundLatLngViaIP, to: true)
    
    index.search(query: query) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Detecting keywords

extension DetectingIntentSnippets {
  
  func detectingKeywords() {
    // Create the rule
    let rule = Rule(objectID: "article-id")
      .set(\.conditions, to: [
        Rule.Condition()
          .set(\.anchoring, to: .startsWith)
          .set(\.pattern, to: .literal("article"))
      ])
      .set(\.consequence, to: Rule.Consequence()
        .set(\.query, to: Query()
          .set(\.restrictSearchableAttributes, to: [
          "title",
          "book_id"
        ])
      )
    )
    // Save the rule
    index.saveRule(rule, forwardToReplicas: true) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}
