//
//  Command+Recommend.swift
//  
//
//  Created by Vladislav Fitc on 31/08/2021.
//

import Foundation

extension Command {

  enum Recommend {

    struct GetRecommendations: AlgoliaCommand {

      let method: HTTPMethod = .post
      let callType: CallType = .read
      let path: RecommendCompletion = .indexesV1 >>> .multiIndex >>> .recommendations
      let body: Data?
      let requestOptions: RequestOptions?

      init(options: [RecommendationsOptions], requestOptions: RequestOptions?) {
        var requestOptions = requestOptions.unwrapOrCreate()
        requestOptions.setHeader("application/json", forKey: .contentType)
        self.requestOptions = requestOptions
        self.body = RequestsWrapper(options).httpBody
      }

    }

  }

}
