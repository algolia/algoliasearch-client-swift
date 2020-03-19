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
    
    let callType: CallType = .write
    let urlRequest: URLRequest
    let requestOptions: RequestOptions?
    
    init(indexName: IndexName,
         requestOptions: RequestOptions?) {
      self.requestOptions = requestOptions
      let path = indexName.toPath()
      urlRequest = .init(method: .delete,
                         path: path,
                         requestOptions: requestOptions)
    }
    
  }
  
  struct Batch: AlgoliaCommand {
    
    let callType: CallType = .write
    let urlRequest: URLRequest
    let requestOptions: RequestOptions?
    
    init<T: Codable>(indexName: IndexName,
         batchOperations: [BatchOperation<T>],
         requestOptions: RequestOptions?) {
      self.requestOptions = requestOptions
      let path = indexName.toPath(withSuffix: "/batch")
      let body = BatchRequest(requests: batchOperations).httpBody
      urlRequest = .init(method: .post,
                         path: path,
                         body: body,
                         requestOptions: requestOptions)
    }
    
  }
  
}
