//
//  Index+Settings.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

extension Index {

  /**
   Get the Settings of an index.
   - parameter requestOptions: Configure request locally with RequestOptions.
   */
  @discardableResult public func getSettings(requestOptions: RequestOptions? = nil,
                                             completion: @escaping ResultCallback<Settings>) -> Operation & TransportTask {
    let command = Command.Settings.GetSettings(indexName: name,
                                               requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Create or change an index’s Settings.
   Only non-null settings are overridden; null settings are left unchanged
   Performance wise, it’s better to setSettings before pushing the data.
   
   - parameter settings: The Settings to be set.
   - parameter resetToDefault: Reset a settings to its default value.
   - parameter forwardToReplicas: Whether to forward the same settings to the replica indices.
   - parameter requestOptions: Configure request locally with RequestOptions.
   */
  @discardableResult public func setSettings(_ settings: Settings,
                                             resetToDefault: [Settings.Key] = [],
                                             forwardToReplicas: Bool? = nil,
                                             requestOptions: RequestOptions? = nil,
                                             completion: @escaping ResultCallback<RevisionIndex>) -> Operation & TransportTask {
    let command = Command.Settings.SetSettings(indexName: name,
                                               settings: settings,
                                               resetToDefault: resetToDefault,
                                               forwardToReplicas: forwardToReplicas,
                                               requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

}

public extension Index {

  func getSettings(requestOptions: RequestOptions? = nil) throws -> Settings {
    let command = Command.Settings.GetSettings(indexName: name,
                                               requestOptions: requestOptions)
    return try execute(command)
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
    return try execute(command)
  }

}
