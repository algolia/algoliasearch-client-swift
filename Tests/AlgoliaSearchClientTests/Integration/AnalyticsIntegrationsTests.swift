//
//  AnalyticsIntegrationTests.swift
//  
//
//  Created by Vladislav Fitc on 28/05/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class AnalyticsIntegrationTests: OnlineTestCase {
  
  override var retryableTests: [() throws -> Void] {
    [
      browsing,
      abTesting,
      aaTesting
    ]
  }
  
  func browsing() throws {
    let analyticsClient = AnalyticsClient(appID: client.applicationID, apiKey: client.apiKey)
    let _ = try analyticsClient.browseAllABTests(hitsPerPage: 3)
  }

  func abTesting() throws {
        
    let analyticsClient = AnalyticsClient(appID: client.applicationID, apiKey: client.apiKey)

    let index1 = client.index(withName: IndexName(rawValue: "\(uniquePrefix())_ab_testing"))
    let index2 = client.index(withName: IndexName(rawValue:"\(uniquePrefix())_ab_testing_dev"))
    
    let save1 = try index1.saveObject(["objectID": "one"] as JSON)
    try AssertWait(save1)
    let save2 = try index2.saveObject(["objectID": "one"] as JSON)
    try AssertWait(save2)
    
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
    try AssertWait(revision)
    
    fetchedABTest = try analyticsClient.getABTest(withID: creation.wrapped.abTestID)
    XCTAssertEqual(fetchedABTest.status, .stopped)

    let deletion = try analyticsClient.deleteABTest(withID: creation.wrapped.abTestID)
    try AssertWait(deletion)

    try AssertThrowsHTTPError(try analyticsClient.getABTest(withID: creation.wrapped.abTestID), statusCode: 404)
  }
    
  func aaTesting() throws {
    
    let analyticsClient = AnalyticsClient(appID: client.applicationID, apiKey: client.apiKey)
    let index = client.index(withName: IndexName(rawValue: "\(uniquePrefix())_aa_testing"))
    
    let saveObject = try index.saveObject(["objectID": "one"])
    try AssertWait(saveObject)
    
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
    try AssertWait(deletion)
    try AssertThrowsHTTPError(try analyticsClient.getABTest(withID: creation.wrapped.abTestID), statusCode: 404)
    
  }

}
