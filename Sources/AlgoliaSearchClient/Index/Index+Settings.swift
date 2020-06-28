//
//  Index+Settings.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

public extension Index {

  // MARK: - Get Settings

  /**
   Get the Settings of an index.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Returns: Async operation
   */
  @discardableResult func getSettings(requestOptions: RequestOptions? = nil,
                                      completion: @escaping ResultCallback<Settings>) -> Operation & TransportTask {
    let command = Command.Settings.GetSettings(indexName: name, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Get the Settings of an index.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Returns: Settings object
   */
  func getSettings(requestOptions: RequestOptions? = nil) throws -> Settings {
    let command = Command.Settings.GetSettings(indexName: name, requestOptions: requestOptions)
    return try execute(command)
  }

  // Set settings

  /**
   Create or change an index’s Settings.
   Only non-null settings are overridden; null settings are left unchanged
   Performance wise, it’s better to setSettings before pushing the data.
   
   - Parameter settings: The Settings to be set.
   - Parameter resetToDefault: Reset a settings to its default value.
   - Parameter forwardToReplicas: Whether to forward the same settings to the replica indices.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Returns: Async operation
   */
  @discardableResult func setSettings(_ settings: Settings,
                                      resetToDefault: [Settings.Key] = [],
                                      forwardToReplicas: Bool? = nil,
                                      requestOptions: RequestOptions? = nil,
                                      completion: @escaping ResultTaskCallback<IndexRevision>) -> Operation & TransportTask {
    let command = Command.Settings.SetSettings(indexName: name,
                                               settings: settings,
                                               resetToDefault: resetToDefault,
                                               forwardToReplicas: forwardToReplicas,
                                               requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Create or change an index’s Settings.
   Only non-null settings are overridden; null settings are left unchanged
   Performance wise, it’s better to setSettings before pushing the data.
   
   - Parameter settings: The Settings to be set.
   - Parameter resetToDefault: Reset a settings to its default value.
   - Parameter forwardToReplicas: Whether to forward the same settings to the replica indices.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Returns: RevisionIndex object
   */
  @discardableResult func setSettings(_ settings: Settings,
                                      resetToDefault: [Settings.Key] = [],
                                      forwardToReplicas: Bool? = nil,
                                      requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<IndexRevision> {
    let command = Command.Settings.SetSettings(indexName: name,
                                               settings: settings,
                                               resetToDefault: resetToDefault,
                                               forwardToReplicas: forwardToReplicas,
                                               requestOptions: requestOptions)
    return try execute(command)
  }

}
