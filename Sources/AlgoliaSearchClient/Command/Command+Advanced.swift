//
//  Command+Advanced.swift
//  
//
//  Created by Vladislav Fitc on 10.03.2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Command {

  enum Advanced {

    struct TaskStatus: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName, taskID: TaskID, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = .indexesV1 >>> .index(indexName) >>> IndexCompletion.task(for: taskID)
        urlRequest = .init(method: .get, path: path, requestOptions: self.requestOptions)
      }
    }

    struct GetLogs: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName?, offset: Int?, length: Int?, logType: LogType, requestOptions: RequestOptions?) {
        let requestOptions = requestOptions.updateOrCreate(
          [:]
            .merging(indexName.flatMap { [.indexName: $0.rawValue] } ?? [:])
            .merging(offset.flatMap { [.offset: String($0)] } ?? [:])
            .merging(length.flatMap { [.length: String($0)] } ?? [:])
            .merging([.type: logType.rawValue])
        )
        self.requestOptions = requestOptions
        urlRequest = .init(method: .get, path: Path.logs, requestOptions: self.requestOptions)
      }

    }

  }

}
