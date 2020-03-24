//
//  Command+Advanced.swift
//  
//
//  Created by Vladislav Fitc on 10.03.2020.
//

import Foundation

extension Command {

  enum Advanced {

    struct TaskStatus: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName,
           taskID: TaskID,
           requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = indexName.toPath(withSuffix: "\(Route.task)/\(taskID.rawValue)")
        urlRequest = .init(method: .get, path: path, requestOptions: requestOptions)
      }
    }

  }

}
