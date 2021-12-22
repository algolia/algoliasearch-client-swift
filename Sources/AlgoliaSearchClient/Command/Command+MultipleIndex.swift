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

      let method: HTTPMethod = .get
      let callType: CallType = .read
      let path = URL.indexesV1
      let requestOptions: RequestOptions?

      init(requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
      }

    }

    struct ListIndexAPIKeys: AlgoliaCommand {

      let method: HTTPMethod = .get
      let callType: CallType = .read
      let path: URL
      let requestOptions: RequestOptions?

      init(requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = URL
          .indexesV1
          .appending(.asterisk)
          .appending(.keys)
      }

    }

    struct Queries: AlgoliaCommand {

      let method: HTTPMethod = .post
      let callType: CallType = .read
      let path: URL
      let body: Data?
      let requestOptions: RequestOptions?

      init(indexName: IndexName,
           queries: [Query],
           strategy: MultipleQueriesStrategy = .none,
           requestOptions: RequestOptions?) {
        let queries = queries
          .map { IndexedQuery(indexName: indexName, query: $0) }
          .map(MultiSearchQuery.init)
        self.init(queries: queries,
                  strategy: strategy,
                  requestOptions: requestOptions)
      }

      init(queries: [IndexedQuery],
           strategy: MultipleQueriesStrategy = .none,
           requestOptions: RequestOptions?) {
        let queries = queries.map(MultiSearchQuery.init)
        self.init(queries: queries,
                  strategy: strategy,
                  requestOptions: requestOptions)
      }

      init(queries: [MultiSearchQuery],
           strategy: MultipleQueriesStrategy = .none,
           requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.body = MultipleQueriesRequest(requests: queries, strategy: strategy).httpBody
        self.path = URL
          .indexesV1
          .appending(.asterisk)
          .appending(.queries)
      }

    }

    struct GetObjects: AlgoliaCommand {

      let method: HTTPMethod = .post
      let callType: CallType = .read
      let path: URL
      let body: Data?
      let requestOptions: RequestOptions?

      init(indexName: IndexName, objectIDs: [ObjectID], attributesToRetreive: [Attribute]?, requestOptions: RequestOptions?) {
        let requests = objectIDs.map { ObjectRequest(indexName: indexName, objectID: $0, attributesToRetrieve: attributesToRetreive) }
        self.init(requests: requests, requestOptions: requestOptions)
      }

      init(requests: [ObjectRequest], requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.body = RequestsWrapper(requests).httpBody
        self.path = URL
          .indexesV1
          .appending(.asterisk)
          .appending(.objects)
      }

    }

    struct BatchObjects: AlgoliaCommand {

      let method: HTTPMethod = .post
      let callType: CallType = .write
      let path: URL
      let body: Data?
      let requestOptions: RequestOptions?

      init(operations: [(IndexName, BatchOperation)], requestOptions: RequestOptions?) {
        self.init(operations: operations.map { IndexBatchOperation(indexName: $0.0, operation: $0.1) }, requestOptions: requestOptions)
      }

      init(operations: [IndexBatchOperation], requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.body = RequestsWrapper(operations).httpBody
        self.path = URL
          .indexesV1
          .appending(.asterisk)
          .appending(.batch)
      }

    }

  }

}
