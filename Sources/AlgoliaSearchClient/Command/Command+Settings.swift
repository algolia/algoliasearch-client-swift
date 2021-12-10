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

      let method: HTTPMethod = .get
      let callType: CallType = .read
      let path: URL
      let requestOptions: RequestOptions?

      init(indexName: IndexName,
           requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = URL
          .indexesV1
          .appending(indexName)
          .appending(.settings)
      }

    }

    struct SetSettings: AlgoliaCommand {

      let method: HTTPMethod = .put
      let callType: CallType = .write
      let path: URL
      let body: Data?
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
        self.path = URL
          .indexesV1
          .appending(indexName)
          .appending(.settings)
        self.body = settings.httpBody
      }

    }

  }

}
