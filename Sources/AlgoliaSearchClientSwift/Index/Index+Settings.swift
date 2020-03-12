//
//  Index+Settings.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

extension Index: SettingsEndpoint {
  
  func getSettings(requestOptions: RequestOptions? = nil,
                   completion: @escaping ResultCallback<Settings>) -> Operation {
    let command = Command.Settings.GetSettings(indexName: name,
                                               requestOptions: requestOptions)
    return performRequest(for: command, completion: completion)
  }
  
  func setSettings(_ settings: Settings,
                   resetToDefault: [Settings.Key] = [],
                   forwardToReplicas: Bool? = nil,
                   requestOptions: RequestOptions? = nil,
                   completion: @escaping ResultCallback<RevisionIndex>) -> Operation {
    let command = Command.Settings.SetSettings(indexName: name,
                                               settings: settings,
                                               resetToDefault: resetToDefault,
                                               forwardToReplicas: forwardToReplicas,
                                               requestOptions: requestOptions)
    return performRequest(for: command, completion: completion)
  }
  
}

extension Index {
  
  func getSettings(requestOptions: RequestOptions? = nil) throws -> Settings {
    let command = Command.Settings.GetSettings(indexName: name,
                                               requestOptions: requestOptions)
    return try performSyncRequest(for: command)
  }
  
  func setSettings(_ settings: Settings,
                   resetToDefault: [Settings.Key] = [],
                   forwardToReplicas: Bool? = nil,
                   requestOptions: RequestOptions? = nil) throws -> RevisionIndex {
    let command = Command.Settings.SetSettings(indexName: name,
                                               settings: settings,
                                               resetToDefault: resetToDefault,
                                               forwardToReplicas: forwardToReplicas,
                                               requestOptions: requestOptions)
    return try performSyncRequest(for: command)
  }

  
}
