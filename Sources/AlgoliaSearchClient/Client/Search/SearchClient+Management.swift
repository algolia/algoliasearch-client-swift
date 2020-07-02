//
//  SearchClient+Management.swift
//  
//
//  Created by Vladislav Fitc on 02/07/2020.
//

import Foundation

public extension SearchClient {
  
  // MARK: - Copy index

  /**
   Make a copy of an index, including its objects, settings, synonyms, and query rules.
   
   - Note: This method enables you to copy the entire index (b, settings, synonyms, and rules) OR one or more of the following index elements:
   - setting
   - synonyms
   - and rules (query rules)
   
   - Parameter scope: Scope set. If empty (.all alias), then all objects and all scopes are copied.
   - Parameter source: IndexName of the source Index
   - Parameter destination: IndexName of the destination Index.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func copy(_ scope: Scope = .all,
                               from source: IndexName,
                               to destination: IndexName,
                               requestOptions: RequestOptions? = nil,
                               completion: @escaping ResultTaskCallback<IndexRevision>) -> Operation & TransportTask {
    index(withName: source).copy(scope, to: destination, requestOptions: requestOptions, completion: completion)
  }

  /**
   Make a copy of an index, including its objects, settings, synonyms, and query rules.
   
   - Note: This method enables you to copy the entire index (objects, settings, synonyms, and rules) OR one or more of the following index elements:
   - setting
   - synonyms
   - and rules (query rules)
   
   - Parameter scope: Scope set. If empty (.all alias), then all objects and all scopes are copied.
   - Parameter source: IndexName of the source Index
   - Parameter destination: IndexName of the destination Index.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: RevisionIndex  object
   */
  @discardableResult func copy(_ scope: Scope = .all,
                               from source: IndexName,
                               to destination: IndexName,
                               requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<IndexRevision> {
    try index(withName: source).copy(scope, to: destination, requestOptions: requestOptions)
  }

  // MARK: - Move index

  /**
   Rename an index. Normally used to reindex your data atomically, without any down time.
   The move index method is a safe and atomic way to rename an index.
   
   - Parameter source: IndexName of the source Index
   - Parameter destination: IndexName of the destination Index.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func move(from source: IndexName,
                               to destination: IndexName,
                               requestOptions: RequestOptions? = nil,
                               completion: @escaping ResultTaskCallback<IndexRevision>) -> Operation & TransportTask {
    index(withName: source).move(to: destination, requestOptions: requestOptions, completion: completion)
  }

  /**
   Rename an index. Normally used to reindex your data atomically, without any down time.
   The move index method is a safe and atomic way to rename an index.
   
   - Parameter source: IndexName of the source Index
   - Parameter destination: IndexName of the destination Index.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: RevisionIndex  object
   */
  @discardableResult func move(from source: IndexName,
                               to destination: IndexName,
                               requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<IndexRevision> {
    try index(withName: source).move(to: destination, requestOptions: requestOptions)
  }
  
}
