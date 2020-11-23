//
//  Command+APIKeys.swift
//  
//
//  Created by Vladislav Fitc on 08/04/2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Command {

  enum APIKey {

    struct Add: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(parameters: APIKeyParameters, requestOptions: RequestOptions?) {
        self.urlRequest = URLRequest(method: .post, path: Path.keysV1, body: parameters.httpBody, requestOptions: requestOptions)
        self.requestOptions = requestOptions
      }

    }

    struct Update: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(apiKey: AlgoliaSearchClient.APIKey, parameters: APIKeyParameters, requestOptions: RequestOptions?) {
        self.urlRequest = URLRequest(method: .put, path: .keysV1 >>> APIKeyCompletion.apiKey(apiKey), body: parameters.httpBody, requestOptions: requestOptions)
        self.requestOptions = requestOptions
      }

    }

    struct Delete: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(apiKey: AlgoliaSearchClient.APIKey, requestOptions: RequestOptions?) {
        self.urlRequest = URLRequest(method: .delete, path: .keysV1 >>> APIKeyCompletion.apiKey(apiKey), requestOptions: requestOptions)
        self.requestOptions = requestOptions
      }

    }

    struct Restore: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(apiKey: AlgoliaSearchClient.APIKey, requestOptions: RequestOptions?) {
        self.urlRequest = URLRequest(method: .post, path: .keysV1 >>> APIKeyCompletion.restoreAPIKey(apiKey), requestOptions: requestOptions)
        self.requestOptions = requestOptions
      }

    }

    struct Get: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(apiKey: AlgoliaSearchClient.APIKey, requestOptions: RequestOptions?) {
        self.urlRequest = URLRequest(method: .get, path: .keysV1 >>> APIKeyCompletion.apiKey(apiKey), requestOptions: requestOptions)
        self.requestOptions = requestOptions
      }

    }

    struct List: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(requestOptions: RequestOptions?) {
        self.urlRequest = URLRequest(method: .get, path: Path.keysV1, requestOptions: requestOptions)
        self.requestOptions = requestOptions
      }

    }

  }

}
