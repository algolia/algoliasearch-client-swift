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
      
  func testFindAnswers() throws {
    let credentials = try Result(catching: { try TestCredentials(environment: .answers) }).mapError({ XCTSkip("\($0)") }).get()
    let client = Client(appID: credentials.applicationID, apiKey: credentials.apiKey)
    let index = client.index(withName: "ted")
    let query = AnswersQuery(query: "when do babies start learning?", queryLanguages: [.english])
      .set(\.attributesForPrediction, to: ["description", "title", "transcript"])
      .set(\.nbHits, to: 20)
    let answers = try index.findAnswers(for: query).hits.compactMap(\.answer)
    XCTAssertFalse(answers.isEmpty)
  }

}
