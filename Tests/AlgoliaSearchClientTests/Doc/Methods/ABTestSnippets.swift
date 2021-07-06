//
//  ABTest.swift
//  
//
//  Created by Vladislav Fitc on 29/06/2020.
//

import Foundation
import AlgoliaSearchClient

struct ABTestSnippets: SnippetsCollection {
  
  var analyticsClient = AnalyticsClient(appID: "", apiKey: "")
}

//MARK: - Set region

extension ABTestSnippets {

  func setRegion() {
    let client = AnalyticsClient(appID: "YourApplicationID",
                                 apiKey: "YourAdminAPIKey",
                                 region: .de /* Defaults to region.US */)
    
    let abTest: ABTest /* The AB test */
      
    /* Just for compilation, don't copy to doc */
    abTest = ABTest(name: "", endAt: .init(), variantA: .init(indexName: "", trafficPercentage: 0), variantB: .init(indexName: "", trafficPercentage: 0))
    /* Just for compilation, don't copy to doc */

    client.addABTest(abTest) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Add A/B test

extension ABTestSnippets {

  static var addSnippet: String = """
  analyticsClient.addABTest(
    _ #{abTest}: __ABTest__,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<WaitableWrapper<ABTestCreation>> -> Void__
  )
  """
  
  func addAbTest() {
    let analyticsClient = AnalyticsClient(appID: "YourApplicationID", apiKey: "YourAdminAPIKey")
    
    let abTest = ABTest(name: "myABTest",
                        endAt: Date().addingTimeInterval(24 * 60 * 60),
                        variantA: .init(indexName: "indexName1",
                                        trafficPercentage: 90,
                                        description: "a description"),
                        variantB: .init(indexName: "indexName2",
                                        trafficPercentage: 10,
                                        description: "a description"))
    
    analyticsClient.addABTest(abTest) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func addAbTestWithCustomSearchParameters() {
    let analyticsClient = AnalyticsClient(appID: "YourApplicationID", apiKey: "YourAdminAPIKey")
    
    let abTest = ABTest(name: "myABTest",
                        endAt: Date().addingTimeInterval(24 * 60 * 60),
                        variantA: .init(indexName: "indexName1",
                                        trafficPercentage: 90,
                                        description: "a description"),
                        variantB: .init(indexName: "indexName2",
                                        trafficPercentage: 10,
                                        customSearchParameters: Query()
                                          .set(\.ignorePlurals, to: true),
                                        description: "a description"))
    
    analyticsClient.addABTest(abTest) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Get A/B test

extension ABTestSnippets {
  
  static var getSnippet: String = """
  analyticsClient.getABTest(
    withID #{abTestID}: __ABTestID__,
    requestOptions: __RequestOptions?__ = nil,
  	completion: __<Result<ABTestResponse>> -> Void__
  )
  """
  
  func getAbTest() {
    analyticsClient.getABTest(withID: 42) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - List A/B tests

extension ABTestSnippets {
  
  static var listSnippet: String = """
  analyticsClient.listABTests(
    #{offset}: __Int?__,
    #{limit}: __Int?__,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<ABTestsResponse> -> Void__
  )
  """
  
  func listAbTest() {
    analyticsClient.listABTests(offset: 10,
                                limit: 20) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Stop A/B test

extension ABTestSnippets {
  
  static var stopSnippet: String = """
  analyticsClient.stopABTest(
    withID #{abTestID}: __ABTestID__,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<WaitableWrapper<ABTestRevision>> -> Void__
  )
  """
  
  func stopAbTest() {
    analyticsClient.stopABTest(withID: 42) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Delete A/B test

extension ABTestSnippets {
  
  static var deleteSnippet: String = """
  analyticsClient.deleteABTest(
    withID #{abTestID}: __ABTestID__,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<WaitableWrapper<ABTestDeletion>> -> Void__
  )
  """
  
  func deleteAbTest() {
    analyticsClient.deleteABTest(withID: 42) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

