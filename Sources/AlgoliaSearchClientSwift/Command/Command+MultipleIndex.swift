//
//  Command+MultipleIndex.swift
//  
//
//  Created by Vladislav Fitc on 04/04/2020.
//

import Foundation

extension Command {
  
  enum MultipleIndex {
    
    struct ListIndices: AlgoliaCommand {
      
      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?
      
      init(requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.urlRequest = .init(method: .get, path: Path.indexesV1, requestOptions: requestOptions)
      }
      
    }
    
    struct ListIndexAPIKeys: AlgoliaCommand {
      
      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?
      
      init(requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.urlRequest = .init(method: .get, path: .indexesV1 >>> .multiIndex >>> MultiIndexCompletion.keys, requestOptions: requestOptions)
      }
      
    }
    
    struct Queries: AlgoliaCommand {
      
      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?
      // TODO:
      init(queries: [IndexQuery], requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.urlRequest = .init(method: .post, path: .indexesV1 >>> .multiIndex >>> MultiIndexCompletion.queries, body: queries.httpBody, requestOptions: requestOptions)
      }
      
    }
    
    struct GetObjects: AlgoliaCommand {
      
      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?
      // TODO:
      init(requests: [RequestObjects], requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.urlRequest = .init(method: .post, path: .indexesV1 >>> .multiIndex >>> MultiIndexCompletion.objects, body: nil, requestOptions: requestOptions)
      }
      
    }
    
    struct BatchObjects: AlgoliaCommand {
      
      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?
      // TODO:
      init(operations: [BatchOperationIndex], requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.urlRequest = .init(method: .post, path: .indexesV1 >>> .multiIndex >>> MultiIndexCompletion.batch, body: nil, requestOptions: requestOptions)
      }
      
    }
    
  }
  
}
