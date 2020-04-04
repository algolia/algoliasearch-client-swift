//
//  Command+Settings.swift
//  
//
//  Created by Vladislav Fitc on 10.03.2020.
//

import Foundation

extension Command {

  enum Settings {

    struct GetSettings: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName,
           requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = indexName.path(with: .settings)
        urlRequest = .init(method: .get,
                           path: path,
                           requestOptions: requestOptions)
      }

    }

    struct SetSettings: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName,
           settings: AlgoliaSearchClientSwift.Settings,
           resetToDefault: [AlgoliaSearchClientSwift.Settings.Key],
           forwardToReplicas: Bool?,
           requestOptions: RequestOptions?) {
        let requestOptions = requestOptions.updateOrCreate({
          guard let forwardToReplicas = forwardToReplicas else { return [:] }
          return [.forwardToReplicas: "\(forwardToReplicas)"]
        }())
        self.requestOptions = requestOptions
        let path = indexName.path(with: .settings)
        urlRequest = .init(method: .put,
                           path: path,
                           body: settings.httpBody,
                           requestOptions: requestOptions)
      }

    }

  }

}
