//
//  RecommendCommandTests.swift
//  
//
//  Created by Vladislav Fitc on 01/09/2021.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class RecommendCommandTests: XCTestCase, AlgoliaCommandTest {
  
  func testGetRecommendations() {
    let options = RecommendationsOptions(indexName: "index1",
                                         model: .relatedProducts,
                                         objectID: "obj1",
                                         threshold: 5,
                                         maxRecommendations: nil,
                                         queryParameters: Query()
                                          .set(\.filters, to: "brand:sony"),
                                         fallbackParameters: Query()
                                          .set(\.filters, to: "price > 100"))
    let command = Command.Recommend.GetRecommendations(options: [options],
                                                       requestOptions: test.requestOptions)
    var testOptions = test.requestOptions
    testOptions.setHeader("application/json", forKey: .contentType)
    check(command: command,
          callType: .read,
          method: .post,
          urlPath: "/1/indexes/*/recommendations",
          queryItems: [
            .init(name: "testParameter", value: "testParameterValue"),
          ],
          body: RequestsWrapper([options]).httpBody,
          requestOptions: testOptions)
  }
    
}
