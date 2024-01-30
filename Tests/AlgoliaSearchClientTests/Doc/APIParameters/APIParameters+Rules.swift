//
//  APIParameters+Rules.swift
//
//
//  Created by Vladislav Fitc on 07/07/2020.
//

import AlgoliaSearchClient
import Foundation

extension APIParameters {
  // MARK: - Rules

  func rules() {
    func enableRules() {
      /*
             enableRules = true|false
             */
      func enable_rules_syntax_by_default() {
        let settings = Settings()
          .set(\.enableRules, to: true)

        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      func enable_rules_search_time() {
        let query = Query("query")
          .set(\.enableRules, to: true)

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
    func filterPromotes() {
      /*
             filterPromotes = true|false
             */
      func enable_filter_promotes() {
        let rule = Rule(objectID: "rule_with_filterPromotes")
          .set(
            \.conditions,
            to: [
              Rule.Condition()
                .set(\.anchoring, to: .is)
                .set(\.pattern, to: .facet("brand"))
            ]
          )
          .set(
            \.consequence,
            to: Rule.Consequence()
              .set(\.filterPromotes, to: true)
              .set(\.promote, to: [.init(objectID: "promoted_items", position: 0)]))

        _ = rule
      }
    }
    func ruleContexts() {
      /*
             ruleContexts = [
             "context_value",
             ...
             ]
             */
      let query = Query("query")
        .set(\.ruleContexts, to: ["front_end", "website2"])

      index.search(query: query) { result in
        if case .success(let response) = result {
          print("Response: \(response)")
        }
      }
    }
  }
}
