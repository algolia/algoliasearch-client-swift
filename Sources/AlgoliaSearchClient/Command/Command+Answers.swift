//
//  Command+Answers.swift
//  
//
//  Created by Vladislav Fitc on 19/11/2020.
//

import Foundation

extension Command {

  enum Answers {

    struct Find: AlgoliaCommand {

      let method: HTTPMethod = .post
      let callType: CallType = .read
      let path: URL
      let body: Data?
      let requestOptions: RequestOptions?

      init(indexName: IndexName,
           query: AnswersQuery,
           requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = URL
          .answers
          .appending(indexName)
          .appending(.prediction)
        self.body = query.httpBody
      }

    }

  }

}
