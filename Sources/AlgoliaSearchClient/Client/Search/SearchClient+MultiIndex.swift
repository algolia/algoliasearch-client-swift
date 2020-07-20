//
//  SearchClient+MultiIndex.swift
//  
//
//  Created by Vladislav Fitc on 04/04/2020.
//

import Foundation

public extension SearchClient {

  // MARK: - List indices

  /**
   Get a list of indices with their associated metadata.
   
   This method retrieves a list of all indices associated with a given ApplicationID.
   The returned list includes the name of the index as well as its associated metadata,
   such as the number of records, size, last build time, and pending tasks.
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func listIndices(requestOptions: RequestOptions? = nil,
                                      completion: @escaping ResultCallback<IndicesListResponse>) -> Operation {
    let command = Command.MultipleIndex.ListIndices(requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Get a list of indices with their associated metadata.
   
   This method retrieves a list of all indices associated with a given ApplicationID.
   The returned list includes the name of the index as well as its associated metadata,
   such as the number of records, size, last build time, and pending tasks.
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: IndicesListResponse  object
   */
  @discardableResult func listIndices(requestOptions: RequestOptions? = nil) throws -> IndicesListResponse {
    let command = Command.MultipleIndex.ListIndices(requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - List index API key

  /**
   Get the full list of API Keys.
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func listIndexAPIKeys(requestOptions: RequestOptions? = nil,
                                           completion: @escaping ResultCallback<ListAPIKeysResponse>) -> Operation {
    let command = Command.MultipleIndex.ListIndexAPIKeys(requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Get the full list of API Keys.
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: ListAPIKeyResponse  object
   */
  @discardableResult func listIndexAPIKeys(requestOptions: RequestOptions? = nil) throws -> ListAPIKeysResponse {
    let command = Command.MultipleIndex.ListIndexAPIKeys(requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Multiple queries

  /**
   Perform a search on several indices at the same time, with one method call.

   - Parameter queries: The list of IndexedQuery objects mathcing index name and a query to execute on it.
   - Parameter strategy: The MultipleQueriesStrategy of the query.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func multipleQueries(queries: [IndexedQuery],
                                          strategy: MultipleQueriesStrategy = .none,
                                          requestOptions: RequestOptions? = nil,
                                          completion: @escaping ResultCallback<SearchesResponse>) -> Operation {
    let command = Command.MultipleIndex.Queries(queries: queries, strategy: strategy, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Perform a search on several indices at the same time, with one method call.
   
   - Parameter queries: The list of IndexedQuery objects mathcing index name and a query to execute on it.
   - Parameter strategy: The MultipleQueriesStrategy of the query.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: SearchesResponse object
   */
  @discardableResult func multipleQueries(queries: [IndexedQuery],
                                          strategy: MultipleQueriesStrategy = .none,
                                          requestOptions: RequestOptions? = nil) throws -> SearchesResponse {
    let command = Command.MultipleIndex.Queries(queries: queries, strategy: strategy, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Multiple get objects

  /**
   Retrieve one or more objects, potentially from different indices, in a single API call.
   Results will be received in the same order as the requests.
   
   - Parameter requests: The list of objects to retrieve.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func multipleGetObjects(requests: [ObjectRequest],
                                             requestOptions: RequestOptions? = nil,
                                             completion: @escaping ResultCallback<ObjectsResponse<JSON>>) -> Operation {
    let command = Command.MultipleIndex.GetObjects(requests: requests, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Retrieve one or more objects, potentially from different indices, in a single API call.
   Results will be received in the same order as the requests.
   
   - Parameter requests: The list of objects to retrieve.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: ObjectsResponse object
   */
  @discardableResult func multipleGetObjects(requests: [ObjectRequest],
                                             requestOptions: RequestOptions? = nil) throws -> ObjectsResponse<JSON> {
    let command = Command.MultipleIndex.GetObjects(requests: requests, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Multiple batch

  /**
   Perform several indexing operations in one API call.
   
   This method enables you to batch multiple different indexing operations in one API call, like add or delete objects, potentially targeting multiple indices.
   
   - Parameter operations: List of IndexName and an associated BatchOperation.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func multipleBatchObjects(operations: [(IndexName, BatchOperation)],
                                               requestOptions: RequestOptions? = nil,
                                               completion: @escaping ResultCallback<WaitableWrapper<BatchesResponse>>) -> Operation {
    let command = Command.MultipleIndex.BatchObjects(operations: operations, requestOptions: requestOptions)
    return execute(command, transform: { .init(batchesResponse: $0, client: self) }, completion: completion)
  }

  /**
   Perform several indexing operations in one API call.
   
   This method enables you to batch multiple different indexing operations in one API call, like add or delete objects, potentially targeting multiple indices.
   
   - Parameter operations: List of IndexName and an associated BatchOperation.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: BatchesResponse object
   */
  @discardableResult func multipleBatchObjects(operations: [(IndexName, BatchOperation)],
                                               requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<BatchesResponse> {
    let command = Command.MultipleIndex.BatchObjects(operations: operations, requestOptions: requestOptions)
    return try execute(command, transform: { .init(batchesResponse: $0, client: self) })
  }

}
