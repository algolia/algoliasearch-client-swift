//
//  InsightsCommandTest.swift
//  
//
//  Created by Vladislav Fitc on 21/12/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class InsightsCommandTest: XCTestCase, AlgoliaCommandTest {
  
  func testSendEvents() throws {
    let event = try InsightsEvent.click(name: "Search User Clicked",
                                        indexName: "testIndex",
                                        userToken: "test_user_token",
                                        queryID: "test query id",
                                        objectIDsWithPositions: [("object1", 1)])
    
    let command = Command.Insights.SendEvents(events: [event], requestOptions: test.requestOptions)
    check(command: command,
          callType: .write,
          method: .post,
          urlPath: "/1/events",
          queryItems: [.init(name: "testParameter", value: "testParameterValue")],
          body: EventsWrapper([event]).httpBody,
          additionalHeaders: [.contentType: "application/json"],
          requestOptions: test.requestOptions)

  }
}
