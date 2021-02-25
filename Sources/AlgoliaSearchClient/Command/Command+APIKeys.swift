//
//  Command+APIKeys.swift
//  
//
//  Created by Vladislav Fitc on 08/04/2020.
//

import Foundation

extension Command {

  enum APIKey {

    struct Add: AlgoliaCommand {

      let method: HTTPMethod = .post
      let callType: CallType = .write
      let path: Path = .keysV1
      let body: Data?
      let requestOptions: RequestOptions?

      init(parameters: APIKeyParameters, requestOptions: RequestOptions?) {
        self.body = parameters.httpBody
        self.requestOptions = requestOptions
      }

    }

    struct Update: AlgoliaCommand {

      let method: HTTPMethod = .put
      let callType: CallType = .write
      let path: APIKeyCompletion
      let body: Data?
      let requestOptions: RequestOptions?

      init(apiKey: AlgoliaSearchClient.APIKey, parameters: APIKeyParameters, requestOptions: RequestOptions?) {
        self.path = (.keysV1 >>> .apiKey(apiKey))
        self.body = parameters.httpBody
        self.requestOptions = requestOptions
      }

    }

    struct Delete: AlgoliaCommand {

      let method: HTTPMethod = .delete
      let callType: CallType = .write
      let path: APIKeyCompletion
      let requestOptions: RequestOptions?

      init(apiKey: AlgoliaSearchClient.APIKey, requestOptions: RequestOptions?) {
        self.path = (.keysV1 >>> .apiKey(apiKey))
        self.requestOptions = requestOptions
      }

    }

    struct Restore: AlgoliaCommand {

      let method: HTTPMethod = .post
      let callType: CallType = .write
      let path: APIKeyCompletion
      let requestOptions: RequestOptions?

      init(apiKey: AlgoliaSearchClient.APIKey, requestOptions: RequestOptions?) {
        self.path = (.keysV1 >>> .restoreAPIKey(apiKey))
        self.requestOptions = requestOptions
      }

    }

    struct Get: AlgoliaCommand {

      let method: HTTPMethod = .get
      let callType: CallType = .read
      let path: APIKeyCompletion
      let requestOptions: RequestOptions?

      init(apiKey: AlgoliaSearchClient.APIKey, requestOptions: RequestOptions?) {
        self.path = (.keysV1 >>> .apiKey(apiKey))
        self.requestOptions = requestOptions
      }

    }

    struct List: AlgoliaCommand {

      let method: HTTPMethod = .get
      let callType: CallType = .read
      let path: Path
      let requestOptions: RequestOptions?

      init(requestOptions: RequestOptions?) {
        self.path = .keysV1
        self.requestOptions = requestOptions
      }

    }

  }

}
