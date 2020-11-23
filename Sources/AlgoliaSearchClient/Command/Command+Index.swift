//
//  Command+Index.swift
//  
//
//  Created by Vladislav Fitc on 19/03/2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Command {

  struct Custom: AlgoliaCommand {
    let callType: CallType
    let urlRequest: URLRequest
    let requestOptions: RequestOptions?
  }

  enum Index {}
}

extension Command.Index {

  struct DeleteIndex: AlgoliaCommand {

    let callType: CallType = .write
    let urlRequest: URLRequest
    let requestOptions: RequestOptions?

    init(indexName: IndexName,
         requestOptions: RequestOptions?) {
      self.requestOptions = requestOptions
      let path = .indexesV1 >>> IndexRoute.index(indexName)
      urlRequest = .init(method: .delete, path: path, requestOptions: self.requestOptions)
    }

  }

  struct Batch: AlgoliaCommand {

    let callType: CallType = .write
    let urlRequest: URLRequest
    let requestOptions: RequestOptions?

    init(indexName: IndexName,
         batchOperations: [BatchOperation],
         requestOptions: RequestOptions?) {
      self.requestOptions = requestOptions
      let path = .indexesV1 >>> .index(indexName) >>> IndexCompletion.batch
      let body = RequestsWrapper(batchOperations).httpBody
      urlRequest = .init(method: .post, path: path, body: body, requestOptions: self.requestOptions)
    }

  }

  struct Operation: AlgoliaCommand {

    let callType: CallType = .write
    let urlRequest: URLRequest
    let requestOptions: RequestOptions?

    init(indexName: IndexName, operation: IndexOperation, requestOptions: RequestOptions?) {
      self.requestOptions = requestOptions
      let path = .indexesV1 >>> .index(indexName) >>> IndexCompletion.operation
      urlRequest = .init(method: .post, path: path, body: operation.httpBody, requestOptions: self.requestOptions)
    }

  }

}
