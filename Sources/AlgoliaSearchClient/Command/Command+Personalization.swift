//
//  Command+Personalization.swift
//  
//
//  Created by Vladislav Fitc on 27/05/2020.
//

import Foundation

extension Command {

  enum Personalization {

    struct Get: AlgoliaCommand {

      let method: HTTPMethod = .get
      let callType: CallType = .read
      let path = URL.strategies.appending(.personalization)
      let requestOptions: RequestOptions?

      init(requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
      }

    }

    struct Set: AlgoliaCommand {

      let method: HTTPMethod = .post
      let callType: CallType = .write
      let path = URL.strategies.appending(.personalization)
      let body: Data?
      let requestOptions: RequestOptions?

      init(strategy: PersonalizationStrategy, requestOptions: RequestOptions?) {
        var requestOptions = requestOptions.unwrapOrCreate()
        requestOptions.setHeader("application/json", forKey: .contentType)
        self.requestOptions = requestOptions
        self.body = strategy.httpBody
      }

    }

  }

}
