//
//  File.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation

protocol SettingsEndpoint {
  
  /**
   Get the Settings of an index.
   - parameter requestOptions: Configure request locally with RequestOptions.
   */
  func getSettings(requestOptions: RequestOptions?,
                   completion: @escaping ResultCallback<Settings>) -> Operation

  /**
   Create or change an index’s Settings.
   Only non-null settings are overridden; null settings are left unchanged
   Performance wise, it’s better to setSettings before pushing the data.
   
   - parameter settings: The Settings to be set.
   - parameter resetToDefault: Reset a settings to its default value.
   - parameter forwardToReplicas: Whether to forward the same settings to the replica indices.
   - parameter requestOptions: Configure request locally with RequestOptions.
   */
  func setSettings(_ settings: Settings,
                   resetToDefault: [Settings.Key],
                   forwardToReplicas: Bool?,
                   requestOptions: RequestOptions?,
                   completion: @escaping ResultCallback<RevisionIndex>) -> Operation
  
}
