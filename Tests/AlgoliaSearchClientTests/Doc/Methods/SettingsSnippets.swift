//
//  SettingsSnippets.swift
//  
//
//  Created by Vladislav Fitc on 01/07/2020.
//

import Foundation
import AlgoliaSearchClient

struct SettingsSnippets: SnippetsCollection {}


//MARK: - Get settings

extension SettingsSnippets {
  
  static var getSettings = """
  index.getSettings(
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<Settings> -> Void__
  )
  """
  
  func getSettings() {
    index.getSettings { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Set settings

extension SettingsSnippets {
  
  static var setSettings = """
  index.setSettings(
    _ #{settings}: __Settings__,
    resetToDefault: __[Settings.Key]__ = [],
    #{forwardToReplicas}: __Bool?__ = nil,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<WaitableWrapper<IndexRevision>> -> Void__
  )
  """
  
  func setSettings() {
    let settings = Settings()
      .set(\.searchableAttributes, to: ["name", "address"])
      .set(\.customRanking, to: [.desc("followers")])
    
    index.setSettings(settings) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Copy settings

extension SettingsSnippets {
  
  static var copySettings = """
  client.copySettings(
    from [source](#method-param-indexnamesrc): __IndexName__,
    to [destination](#method-param-indexnamedest): __IndexName__,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<WaitableWrapper<IndexRevision>> -> Void__
  )
  """
  
  func copySettings() {
    client.copySettings(from: "indexNameSrc", to: "indexNameDest") { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

