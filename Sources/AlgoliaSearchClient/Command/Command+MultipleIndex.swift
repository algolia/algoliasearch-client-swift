//
//  Command+MultipleIndex.swift
//  
//
//  Created by Vladislav Fitc on 04/04/2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

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
        self.urlRequest = .init(method: .get, path: .indexesV1 >>> .multiIndex >>> MultiIndexCompletion.keys, requestOptions: self.requestOptions)
      }

    }

    struct Queries: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName, queries: [Query], strategy: MultipleQueriesStrategy = .none, requestOptions: RequestOptions?) {
        let queries = queries.map { IndexedQuery(indexName: indexName, query: $0) }
        self.init(queries: queries, strategy: strategy, requestOptions: requestOptions)
      }

      init(queries: [IndexedQuery], strategy: MultipleQueriesStrategy = .none, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let body = MultipleQueriesRequest(requests: queries, strategy: strategy).httpBody
        self.urlRequest = .init(method: .post, path: .indexesV1 >>> .multiIndex >>> MultiIndexCompletion.queries, body: body, requestOptions: self.requestOptions)
      }

    }

    struct GetObjects: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName, objectIDs: [ObjectID], attributesToRetreive: [Attribute]?, requestOptions: RequestOptions?) {
        let requests = objectIDs.map { ObjectRequest(indexName: indexName, objectID: $0, attributesToRetrieve: attributesToRetreive) }
        self.init(requests: requests, requestOptions: requestOptions)
      }

      init(requests: [ObjectRequest], requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let body = RequestsWrapper(requests).httpBody
        self.urlRequest = .init(method: .post, path: .indexesV1 >>> .multiIndex >>> MultiIndexCompletion.objects, body: body, requestOptions: self.requestOptions)
      }

    }

    struct BatchObjects: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(operations: [(IndexName, BatchOperation)], requestOptions: RequestOptions?) {
        self.init(operations: operations.map { IndexBatchOperation(indexName: $0.0, operation: $0.1) }, requestOptions: requestOptions)
      }

      init(operations: [IndexBatchOperation], requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let body = RequestsWrapper(operations).httpBody
        self.urlRequest = .init(method: .post, path: .indexesV1 >>> .multiIndex >>> MultiIndexCompletion.batch, body: body, requestOptions: self.requestOptions)
      }

    }

  }

}
