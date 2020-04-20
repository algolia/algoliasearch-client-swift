//
//  Client+MultiIndex.swift
//  
//
//  Created by Vladislav Fitc on 04/04/2020.
//

import Foundation

public extension Client {

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
  @discardableResult func listIndices(requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<IndicesListResponse>) -> Operation {
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
  @discardableResult func listIndexAPIKeys(requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<[APIKeyResponse]>) -> Operation {
    let command = Command.MultipleIndex.ListIndexAPIKeys(requestOptions: requestOptions)
    return execute(command, transform: \ListAPIKeysResponse.keys, completion: completion)
  }

  /**
   Get the full list of API Keys.
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: ListAPIKeyResponse  object
   */
  @discardableResult func listIndexAPIKeys(requestOptions: RequestOptions? = nil) throws -> [APIKeyResponse] {
    let command = Command.MultipleIndex.ListIndexAPIKeys(requestOptions: requestOptions)
    return try execute(command, transform: \ListAPIKeysResponse.keys)
  }

  // MARK: - Multiple queries

  /**
   Perform a search on several indices at the same time, with one method call.

   - Parameter queries: The IndexQuery that will execute each Query against its IndexName
   - Parameter strategy: The MultipleQueriesStrategy of the query.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func multipleQueries(queries: [(IndexName, Query)], strategy: MultipleQueriesStrategy? = nil, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<[SearchResponse]>) -> Operation {
    let command = Command.MultipleIndex.Queries(queries: queries, strategy: strategy, requestOptions: requestOptions)
    return execute(command, transform: \SearchesResponse.results, completion: completion)
  }

  /**
   Perform a search on several indices at the same time, with one method call.
   
   - Parameter queries: The IndexQuery that will execute each Query against its IndexName
   - Parameter strategy: The MultipleQueriesStrategy of the query.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: List of SearchResponse  object
   */
  @discardableResult func multipleQueries(queries: [(IndexName, Query)], strategy: MultipleQueriesStrategy? = nil, requestOptions: RequestOptions? = nil) throws -> [SearchResponse] {
    let command = Command.MultipleIndex.Queries(queries: queries, strategy: strategy, requestOptions: requestOptions)
    return try execute(command, transform: \SearchesResponse.results)
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
  @discardableResult func multipleGetObjects(requests: [ObjectRequest], requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<ObjectsResponse<JSON>>) -> Operation {
    let command = Command.MultipleIndex.GetObjects(requests: requests, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Retrieve one or more objects, potentially from different indices, in a single API call.
   Results will be received in the same order as the requests.
   
   - Parameter requests: The list of objects to retrieve.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: ObjectsResponse  object
   */
  @discardableResult func multipleGetObjects(requests: [ObjectRequest], requestOptions: RequestOptions? = nil) throws -> ObjectsResponse<JSON> {
    let command = Command.MultipleIndex.GetObjects(requests: requests, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Multiple batch

  /**
   Perform several indexing operations in one API call.
   This method enables you to batch multiple different indexing operations in one API call, like add or delete
   objects, potentially targeting multiple indices.
   
   - Parameter operations: List of IndexName and an associated BatchOperation.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func multipleBatchObjects(operations: [(IndexName, BatchOperation)], requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<BatchesResponse>) -> Operation {
    let command = Command.MultipleIndex.BatchObjects(operations: operations, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Perform several indexing operations in one API call.
   This method enables you to batch multiple different indexing operations in one API call, like add or delete
   objects, potentially targeting multiple indices.
   
   - Parameter operations: List of IndexName and an associated BatchOperation.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: BatchesResponse  object
   */
  @discardableResult func multipleBatchObjects(operations: [(IndexName, BatchOperation)], requestOptions: RequestOptions? = nil) throws -> BatchesResponse {
    let command = Command.MultipleIndex.BatchObjects(operations: operations, requestOptions: requestOptions)
    return try execute(command)
  }

}
