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
      
      init(indexName: IndexName, queries: [Query], strategy: MultipleQueriesStrategy?, requestOptions: RequestOptions?) {
        let queries = queries.map { IndexQuery(indexName: indexName, query: $0) }
        self.init(queries: queries, strategy: strategy, requestOptions: requestOptions)
      }
      
      init(queries: [(IndexName, Query)], strategy: MultipleQueriesStrategy?, requestOptions: RequestOptions?) {
        let queries = queries.map { IndexQuery(indexName: $0.0, query: $0.1) }
        self.init(queries: queries, strategy: strategy, requestOptions: requestOptions)
      }

      init(queries: [IndexQuery], strategy: MultipleQueriesStrategy?, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let body = MultipleQueriesRequest(requests: queries, strategy: strategy).httpBody
        self.urlRequest = .init(method: .post, path: .indexesV1 >>> .multiIndex >>> MultiIndexCompletion.queries, body: body, requestOptions: requestOptions)
      }
      
    }
    
    struct GetObjects: AlgoliaCommand {
      
      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(requests: [ObjectRequest], requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let body = RequestsWrapper(requests).httpBody
        self.urlRequest = .init(method: .post, path: .indexesV1 >>> .multiIndex >>> MultiIndexCompletion.objects, body: body, requestOptions: requestOptions)
      }
      
    }
    
    struct BatchObjects: AlgoliaCommand {
      
      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(operations: [BatchOperationIndex], requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let body = RequestsWrapper(operations).httpBody
        self.urlRequest = .init(method: .post, path: .indexesV1 >>> .multiIndex >>> MultiIndexCompletion.batch, body: body, requestOptions: requestOptions)
      }
      
    }
    
  }
  
}
