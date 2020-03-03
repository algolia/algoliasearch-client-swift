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
    let path = name.toPath(withSuffix: "/\(Route.settings)")
    let request = HTTPRequest(transport: transport,
                              method: .get,
                              callType: .read,
                              path: path,
                              requestOptions: requestOptions,
                              completion: completion)
    queue.addOperation(request)
  }
  
  func setSettings(_ settings: Settings,
                   resetToDefault: [Settings.Key] = [],
                   forwardToReplicas: Bool? = nil,
                   requestOptions: RequestOptions? = nil,
                   completion: @escaping ResultCallback<RevisionIndex>) {
    let requestOptions = requestOptions.withParameters({
      guard let forwardToReplicas = forwardToReplicas else { return [:] }
      return [.forwardToReplicas: "\(forwardToReplicas)"]
    }())
    let path = name.toPath(withSuffix: "\(Route.settings)")
    let request = HTTPRequest(transport: transport,
                              method: .put,
                              callType: .write,
                              path: path,
                              body: settings.httpBody,
                              requestOptions: requestOptions,
                              completion: completion)
    queue.addOperation(request)

  }
  
}
