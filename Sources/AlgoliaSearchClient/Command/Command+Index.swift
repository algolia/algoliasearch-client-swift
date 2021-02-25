//
//  Command+Index.swift
//  
//
//  Created by Vladislav Fitc on 19/03/2020.
//

import Foundation

extension Command {
  enum Index {}
}

extension Command.Index {

  struct DeleteIndex: AlgoliaCommand {

    let method: HTTPMethod = .delete
    let callType: CallType = .write
    let path: IndexRoute
    let requestOptions: RequestOptions?

    init(indexName: IndexName,
         requestOptions: RequestOptions?) {
      self.requestOptions = requestOptions
      self.path = (.indexesV1 >>> .index(indexName))
    }

  }

  struct Batch: AlgoliaCommand {

    let method: HTTPMethod = .post
    let callType: CallType = .write
    let path: IndexCompletion
    let body: Data?
    let requestOptions: RequestOptions?

    init(indexName: IndexName,
         batchOperations: [BatchOperation],
         requestOptions: RequestOptions?) {
      self.requestOptions = requestOptions
      self.path = (.indexesV1 >>> .index(indexName) >>> IndexCompletion.batch)
      self.body = RequestsWrapper(batchOperations).httpBody
    }

  }

  struct Operation: AlgoliaCommand {

    let method: HTTPMethod = .post
    let callType: CallType = .write
    let path: IndexCompletion
    let body: Data?
    let requestOptions: RequestOptions?

    init(indexName: IndexName, operation: IndexOperation, requestOptions: RequestOptions?) {
      self.requestOptions = requestOptions
      self.path = (.indexesV1 >>> .index(indexName) >>> .operation)
      self.body = operation.httpBody
    }

  }

}
