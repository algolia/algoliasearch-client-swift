//
//  Command+Settings.swift
//  
//
//  Created by Vladislav Fitc on 10.03.2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Command {

  enum Settings {

    struct GetSettings: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName,
           requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = .indexesV1 >>> .index(indexName) >>> IndexCompletion.settings
        urlRequest = .init(method: .get, path: path, requestOptions: self.requestOptions)
      }

    }

    struct SetSettings: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName,
           settings: AlgoliaSearchClient.Settings,
           resetToDefault: [AlgoliaSearchClient.Settings.Key],
           forwardToReplicas: Bool?,
           requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions.updateOrCreate({
          guard let forwardToReplicas = forwardToReplicas else { return [:] }
          return [.forwardToReplicas: "\(forwardToReplicas)"]
        }())
        let path = .indexesV1 >>> .index(indexName) >>> IndexCompletion.settings
        urlRequest = .init(method: .put, path: path, body: settings.httpBody, requestOptions: self.requestOptions)
      }

    }

  }

}
