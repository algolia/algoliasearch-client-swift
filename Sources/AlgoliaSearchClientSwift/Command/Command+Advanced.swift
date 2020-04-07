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

      init(indexName: IndexName, taskID: TaskID, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = .indexesV1 >>> .index(indexName) >>> IndexCompletion.task(for: taskID)
        urlRequest = .init(method: .get, path: path, requestOptions: requestOptions)
      }
    }
    
    struct GetLogs: AlgoliaCommand {
      
      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?
      
      init(indexName: IndexName, page: Int? = 0, hitsPerPage: Int? = 0, logType: LogType, requestOptions: RequestOptions?) {
        let requestOptions = requestOptions.updateOrCreate(
          [
            .indexName: indexName.rawValue,
            .offset: page.flatMap(String.init),
            .length: hitsPerPage.flatMap(String.init),
            .type: logType.rawValue
          ]
        )
        self.requestOptions = requestOptions
        urlRequest = .init(method: .get, path: Path.logs, requestOptions: requestOptions)
      }
      
    }

  }

}
