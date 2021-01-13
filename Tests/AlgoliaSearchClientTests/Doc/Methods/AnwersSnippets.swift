//
//  AnswersSnippets.swift
//  
//
//  Created by Vladislav Fitc on 13/01/2021.
//

import Foundation
import AlgoliaSearchClient

struct AnswersSnippets: SnippetsCollection {}

extension AnswersSnippets {

  func findAnswers() {
    let query = AnswersQuery(query: "when do babies start learning")
      .set(\.queryLanguages, to: [.english])
      .set(\.attributesForPrediction, to: ["description", "title", "transcript"])
      .set(\.nbHits, to: 20)
    
    index.findAnswers(for: query) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}
