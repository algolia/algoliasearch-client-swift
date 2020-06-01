//
//  AnalyticsIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 28/05/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class AnalyticsIntegrationTests: OnlineTestCase {
  
  func testBrowsing() throws {
    let analyticsClient = AnalyticsClient(appID: client.applicationID, apiKey: client.apiKey)
    let abTests = try analyticsClient.browseAllABTests(hitsPerPage: 3)
  }

  func testABTesting() throws {
    
    let analyticsClient = AnalyticsClient(appID: client.applicationID, apiKey: client.apiKey)

    let index1 = client.index(withName: "ab_testing")
    let index2 = client.index(withName: "ab_testing_dev")
    
    try index1.saveObject(["objectID": "one"] as JSON).wait()
    try index2.saveObject(["objectID": "one"] as JSON).wait()
    
    let abTestName = TestIdentifier().rawValue
    let abTestEndDate = Date().addingTimeInterval(.day)
    
    let abTest = ABTest(
      name: abTestName,
      endAt: abTestEndDate,
      variantA: .init(indexName: index1.name, trafficPercentage: 60, description: "a description"),
      variantB: .init(indexName: index2.name, trafficPercentage: 40))
    
    let creation = try analyticsClient.addABTest(abTest)
    
    var fetchedABTest = try analyticsClient.getABTest(withID: creation.wrapped.abTestID)
    
    XCTAssertEqual(fetchedABTest.abTestID, creation.wrapped.abTestID)
    XCTAssertEqual(fetchedABTest.name, abTestName)
    XCTAssertEqual(fetchedABTest.endAt.timeIntervalSinceReferenceDate, abTest.endAt.timeIntervalSinceReferenceDate, accuracy: 1)
    XCTAssertEqual(fetchedABTest.variantA.trafficPercentage, 60)
    XCTAssertEqual(fetchedABTest.variantB.trafficPercentage, 40)
    XCTAssertNotEqual(fetchedABTest.status, .stopped)
    
    let revision = try analyticsClient.stopABTest(withID: creation.wrapped.abTestID)
    try revision.wait()
    
    fetchedABTest = try analyticsClient.getABTest(withID: creation.wrapped.abTestID)
    XCTAssertEqual(fetchedABTest.status, .stopped)

    let deletion = try analyticsClient.deleteABTest(withID: creation.wrapped.abTestID)
    try deletion.wait()
    try AssertThrowsNotFound(try analyticsClient.getABTest(withID: creation.wrapped.abTestID))
  }
  
  func testAATesting() throws {
    
    let analyticsClient = AnalyticsClient(appID: client.applicationID, apiKey: client.apiKey)
    let index = client.index(withName: "aa_testing")
    
    try index.saveObject(["objectID": "one"]).wait()
    
    let abTestName = TestIdentifier().rawValue
    let abTestEndDate = Date().addingTimeInterval(.day)
    
    let abTest = ABTest(
      name: abTestName,
      endAt: abTestEndDate,
      variantA: .init(indexName: index.name, trafficPercentage: 90),
      variantB: .init(indexName: index.name, trafficPercentage: 10, customSearchParameters: Query().set(\.ignorePlurals, to: true))
    )
    
    let creation = try analyticsClient.addABTest(abTest)
    
    let fetchedABTest = try analyticsClient.getABTest(withID: creation.wrapped.abTestID)
    
    XCTAssertEqual(fetchedABTest.abTestID, creation.wrapped.abTestID)
    XCTAssertEqual(fetchedABTest.name, abTestName)
    XCTAssertEqual(fetchedABTest.endAt.timeIntervalSinceReferenceDate, abTest.endAt.timeIntervalSinceReferenceDate, accuracy: 1)
    XCTAssertEqual(fetchedABTest.variantA.trafficPercentage, 90)
    XCTAssertEqual(fetchedABTest.variantB.trafficPercentage, 10)
    XCTAssertNotEqual(fetchedABTest.status, .stopped)

    let deletion = try analyticsClient.deleteABTest(withID: creation.wrapped.abTestID)
    try deletion.wait()
    try AssertThrowsNotFound(try analyticsClient.getABTest(withID: creation.wrapped.abTestID))
    
  }

}
