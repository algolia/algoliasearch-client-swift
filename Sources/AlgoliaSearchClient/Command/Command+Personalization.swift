//
//  Command+Personalization.swift
//  
//
//  Created by Vladislav Fitc on 27/05/2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Command {

  enum Personalization {

    struct Get: AlgoliaCommand {
      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(requestOptions: RequestOptions?) {

        self.requestOptions = requestOptions
        self.urlRequest = .init(method: .get, path: .strategies >>>  PersonalizationRoute.personalization, requestOptions: self.requestOptions)
      }

    }

    struct Set: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(strategy: PersonalizationStrategy, requestOptions: RequestOptions?) {
        var requestOptions = requestOptions.unwrapOrCreate()
        requestOptions.setHeader("application/json", forKey: .contentType)
        self.requestOptions = requestOptions
        self.urlRequest = .init(method: .post, path: .strategies >>> PersonalizationRoute.personalization, body: strategy.httpBody, requestOptions: self.requestOptions)
      }

    }

  }

}
