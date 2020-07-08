//
//  InsightsSnippets.swift
//  
//
//  Created by Vladislav Fitc on 01/07/2020.
//

import Foundation
import AlgoliaSearchClient

struct InsightsSnippets: SnippetsCollection {
  
  let insightsClient = InsightsClient(appID: "", apiKey: "")
  
  
}

//MARK: - Clicked Object IDs After Search

extension InsightsSnippets {
  
  static var clickedObjectIDsAfterSearch = """
  insightsClient.sendEvent(.click(
    #{name}: __EventName__,
    #{indexName}: __IndexName__,
    #{userToken}: __UserToken?__,
    #{timestamp}: __Date?__ = nil,
    #{queryID}: __QueryID__,
    #{objectIDs}With#{Positions}: __[(ObjectID, Int)]__)
  )
  """
  
  func clickedObjectIDsAfterSearch() {
    try! insightsClient.sendEvent(.click(
      name: "eventName",
      indexName: "indexName",
      userToken: "user-id",
      queryID: "queryID",
      objectIDsWithPositions: [
        ("objectID1", 17),
        ("objectID2", 19)
      ])
    )
  }
  
}

//MARK: - Clicked Object IDs

extension InsightsSnippets {
  
  static var clickedObjectIDs = """
  """
  
  func clickedObjectIDs() {
    
  }
  
}

//MARK: - Clicked Filters

extension InsightsSnippets {
  
  static var clickedFilters = """
  """
  
  func clickedFilters() {
    
  }
  
}

//MARK: - Converted Objects IDs After Search

extension InsightsSnippets {
  
  static var convertedObjectsIDsAfterSearch = """
  """
  
  func convertedObjectsIDsAfterSearch() {
    
  }
  
}

//MARK: - Converted Object IDs

extension InsightsSnippets {
  
  static var convertedObjectIDs = """
  """
  
  func convertedObjectIDs() {
    
  }
  
}

//MARK: - Converted Filters

extension InsightsSnippets {
  
  static var convertedFilters = """
  """
  
  func convertedFilters() {
    
  }
  
}

//MARK: - Viewed Object IDs

extension InsightsSnippets {
  
  static var viewedObjectIDs = """
  """
  
  func viewedObjectIDs() {
    
  }
  
}

//MARK: - Viewed Filters

extension InsightsSnippets {
  
  static var viewedFilters = """
  """
  
  func viewedFilters() {
    
  }
  
}

