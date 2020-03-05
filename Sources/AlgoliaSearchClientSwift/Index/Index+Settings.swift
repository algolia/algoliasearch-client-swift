//
//  File.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

extension Index: SettingsEndpoint {
  
  func getSettings(requestOptions: RequestOptions? = nil,
                   completion: @escaping ResultCallback<Settings>) {
    let endpoint = Request.Settings.GetSettings(indexName: name,
                                                requestOptions: requestOptions)
    performRequest(for: endpoint, completion: completion)
  }
  
  func setSettings(_ settings: Settings,
                   resetToDefault: [Settings.Key] = [],
                   forwardToReplicas: Bool? = nil,
                   requestOptions: RequestOptions? = nil,
                   completion: @escaping ResultCallback<RevisionIndex>) {
    let endpoint = Request.Settings.SetSettings(indexName: name,
                                                settings: settings,
                                                resetToDefault: resetToDefault,
                                                forwardToReplicas: forwardToReplicas,
                                                requestOptions: requestOptions)
    performRequest(for: endpoint, completion: completion)
  }
  
}
