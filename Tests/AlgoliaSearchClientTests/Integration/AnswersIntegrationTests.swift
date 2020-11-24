//
//  AnswersIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 19/11/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class AnswersIntegrationTests: XCTestCase {
    
  func testSearch() throws {
    guard let rawAppID = String(environmentVariable: "ALGOLIA_ANSWERS_APPLICATION_ID"),
          let rawApiKey = String(environmentVariable: "ALGOLIA_ANSWERS_API_KEY") else {
      throw XCTSkip("Missing Answers credentials")
    }
    let index = Client(appID: ApplicationID(rawValue: rawAppID), apiKey: APIKey(rawValue: rawApiKey)).index(withName: "ted")
    let query = AnswersQuery(query: "when do babies start learning?")
      .set(\.queryLanguages, to: [.english])
      .set(\.attributesForPrediction, to: ["description", "title", "transcript"])
      .set(\.nbHits, to: 20)
    let expectation = self.expectation(description: "response expectation")
    index.findAnswers(for: query) { result in
      switch result {
      case .success(let response):
        let answers = response.hits.compactMap(\.answer)
        for answer in answers {
          print(answer.extract.taggedString.input)
        }
        
      case .failure(let error):
        print(error)
      }
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10, handler: nil)
  }


}
