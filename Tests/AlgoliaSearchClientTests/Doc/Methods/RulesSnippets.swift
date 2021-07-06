//
//  RulesSnippets.swift
//  
//
//  Created by Vladislav Fitc on 29/06/2020.
//

import Foundation
import AlgoliaSearchClient

struct RulesSnippets: SnippetsCollection {}

//MARK: - Save rule

extension RulesSnippets {
  static var saveRuleSnippetBasic = """
  index.saveRule(
    _ #{rule}: __Rule__,
    #{forwardToReplicas}: __Bool?__ = nil,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<WaitableWrapper<IndexRevision>> -> Void__
  )
  """
    
  func saveRuleBasic() {
    let rule = Rule(objectID: "a-rule-id")
      .set(\.isEnabled, to: false)
      .set(\.conditions, to: [
        Rule.Condition()
          .set(\.anchoring, to: .contains)
          .set(\.pattern, to: .literal("smartphone"))
      ])
      .set(\.consequence, to: Rule.Consequence()
        .set(\.query, to: Query()
          .set(\.filters, to: "category = 1")
        )
      )
      .set(\.validity, to: [
        TimeRange(from: Date(),
                  until: Date().addingTimeInterval(10 * 24 * 60 * 60))
        ]
      )
    
    index.saveRule(rule, forwardToReplicas: true) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func saveRuleAlternatives() {
    let rule = Rule(objectID: "a-rule-id")
      .set(\.conditions, to: [
        Rule.Condition()
          .set(\.anchoring, to: .contains)
          .set(\.pattern, to: .literal("smartphone"))
          .set(\.alternatives, to: .true)
      ])
      .set(\.consequence, to: Rule.Consequence()
        .set(\.query, to: Query()
          .set(\.filters, to: "category = 1")
        )
      )
    
    index.saveRule(rule, forwardToReplicas: true) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }

    
  func saveRuleContextBased() {
    let rule = Rule(objectID: "a-rule-id")
      .set(\.conditions, to: [
        Rule.Condition().set(\.context, to: "mobile")
      ])
      .set(\.consequence, to: Rule.Consequence()
        .set(\.query, to: Query()
          .set(\.filters, to: "release_date >= 1568498400")
        )
      )
    
    index.saveRule(rule, forwardToReplicas: true) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Batch Rules

extension RulesSnippets {
  static var batchRulesSnippet = """
  index.saveRules(
    _ #{rules}: __[Rule]__,
    #{forwardToReplicas}: __Bool?__ = nil,
    #{clearExistingRules}: __Bool?__ = nil,
  	requestOptions: __RequestOptions?__ = nil,
    completion: __Result<WaitableWrapper<IndexRevision>> -> Void__
  )
  """
  
  func batchRules() {
    let rules: [Rule] = [/* Your Query rules */]
    
    index.saveRules(rules,
                    forwardToReplicas: true,
                    clearExistingRules: true) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
}

//MARK: - Get Rule

extension RulesSnippets {
  static var getRuleSnippet = """
  index.getRule(
    withID #{objectID}: __ObjectID__,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<Rule> -> Void__
  )
  """
  
  func getRule() {
    index.getRule(withID: "a-rule-id") { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
}

//MARK: - Delete Rule

extension RulesSnippets {
  static var deleteRuleSnippet = """
  index.deleteRule(
    withID #{objectID}: __ObjectID__,
    #{forwardToReplicas}: __Bool?__ = nil,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<WaitableWrapper<IndexRevision>> -> Void__
  )
  """
  
  func deleteRule() {
    // Delete a Rule from the index.
    index.deleteRule(withID: "a-rule-id") { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }

    // Delete a Rule from the index and all its replicas.
    index.deleteRule(withID: "a-rule-id",
                     forwardToReplicas: true) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
}

//MARK: - Clear Rules

extension RulesSnippets {
  static var clearRulesSnippet = """
  index.clearRules(
    #{forwardToReplicas}: __Bool?__ = nil,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<WaitableWrapper<IndexRevision>> -> Void__
  )
  """
  
  func clearRules() {
    // Delete all rules in the index.
    index.clearRules { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
    
    // Delete all rules in the index and all its replicas.
    index.clearRules(forwardToReplicas: true) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
}

//MARK: - Search rules

extension RulesSnippets {
  static var searchRulesSnippet = """
  index.searchRules(
    _ #{query}: __RuleQuery__,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<RuleSearchResponse> -> Void__
  )
  """
  
  func searchRules() {
    let query = RuleQuery()
      .set(\.anchoring, to: .is)
      .set(\.page, to: 1)
      .set(\.hitsPerPage, to: 10)
      .set(\.context, to: "something")
    
    index.searchRules(query) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Replace all rules

extension RulesSnippets {
  static var replaceAllRulesSnippet = """
  index.replaceAllRules(
    with #{rules}: __[Rule]__,
    #{forwardToReplicas}: __Bool?__ = nil,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<WaitableWrapper<IndexRevision>> -> Void__
  )
  """
  
  func replaceAllRules() {
    let client = SearchClient(appID: "YourApplicationID", apiKey: "YourAdminAPIKey")
    let index = client.index(withName: "your_index_name")
    
    let rules: [Rule] = [/* Fetch your rules */]
    
    index.replaceAllRules(with: rules) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
    
    // Or if you want to also replace synonyms on replicas
    index.replaceAllRules(with: rules,
                          forwardToReplicas: true) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
}

//MARK: - Copy rules

extension RulesSnippets {
  
  static var copyRulesSnippet = """
  client.copyRules(
    from [source](#method-param-indexnamesrc): __IndexName__,
    to [destination](#method-param-indexnamedest): __IndexName__,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<WaitableWrapper<IndexRevision>> -> Void__
  )
  """
  
  func copyRules() {
    client.copyRules(from: "indexNameSrc", to: "indexNameDest") { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
}

//MARK: - Export Rules

extension RulesSnippets {
  
  static var exportRulesSnippet = """
  index.browseRules(
    query: __RuleQuery__ = .init(),
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<[RuleSearchResponse]> -> Void__
  )
  """
  
  func exportRules() {
    index.browseRules { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

