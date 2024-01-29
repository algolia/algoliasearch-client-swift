//
//  InsightsIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 23/04/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class InsightsIntegrationTests: IntegrationTestCase {
  
  override var indexNameSuffix: String? {
    return "sending_events"
  }
  
  override var retryableTests: [() throws -> Void] {
    [insights]
  }

  func insights() throws {    
    let insightsClient = InsightsClient(appID: client.applicationID, apiKey: client.apiKey)
    
    let records: [JSON] = [
      ["objectID": "one"],
      ["objectID": "two"]
    ]
    
    try index.saveObjects(records).wait()
    
    let timestamp = Date().addingTimeInterval(-.days(2))
    let event = try InsightsEvent.click(name: "foo", indexName: index.name, userToken: "bar", timestamp: timestamp, objectIDs: ["one", "two"])
    try insightsClient.sendEvent(event)
    
    let events: [InsightsEvent] = [
      try .click(name: "foo", indexName: index.name, userToken: "bar", timestamp: timestamp, objectIDs: ["one", "two"]),
      try .click(name: "foo", indexName: index.name, userToken: "bar", timestamp: timestamp, objectIDs: ["one", "two"]),
    ]
    try insightsClient.sendEvents(events)
    
    let queryID = try index.search(query: Query.empty.set(\.clickAnalytics, to: true)).queryID
    XCTAssertNotNil(queryID)
    
    let eventsAfterSearch = [
      try InsightsEvent.view(name: "foo", indexName: index.name, userToken: "bar", filters: ["filter:foo", "filter:bar"]),
      try InsightsEvent.view(name: "foo", indexName: index.name, userToken: "bar", objectIDs: ["one", "two"]),
      try InsightsEvent.click(name: "foo", indexName: index.name, userToken: "bar", queryID: queryID!, objectIDsWithPositions: [("one", 1), ("two", 2)]),
      try InsightsEvent.click(name: "foo", indexName: index.name, userToken: "bar", filters: ["filter:foo", "filter:bar"]),
      try InsightsEvent.click(name: "foo", indexName: index.name, userToken: "bar", objectIDs: ["one", "two"]),
      try InsightsEvent.conversion(name: "foo", indexName: index.name, userToken: "bar", queryID: nil, objectIDs: ["one", "two"]),
      try InsightsEvent.conversion(name: "foo", indexName: index.name, userToken: "bar", queryID: nil, filters: ["filter:foo", "filter:bar"]),
      try InsightsEvent.conversion(name: "foo", indexName: index.name, userToken: "bar", queryID: queryID!, objectIDs: ["one", "two"]),
      try InsightsEvent.conversion(name: "foo", indexName: index.name, userToken: "bar", queryID: queryID!, filters: ["filter:foo", "filter:bar"])
    ]

    try insightsClient.sendEvents(eventsAfterSearch)

  }
  
}
