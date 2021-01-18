//
//  Command+Answers.swift
//  
//
//  Created by Vladislav Fitc on 19/11/2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Command {

  enum Answers {

    struct Find: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName,
           query: AnswersQuery,
           requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path: IndexCompletion = .answers >>> .index(indexName) >>> .prediction
        urlRequest = .init(method: .post, path: path, body: query.httpBody, requestOptions: self.requestOptions)
      }

    }

  }

}
