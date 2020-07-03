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
   
   - Parameter source: IndexName of the source Index
   - Parameter destination: IndexName of the destination Index.
   - Parameter scope: Scope set. If empty (.all alias), then all objects and all scopes are copied.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func copyIndex(from source: IndexName,
                                    to destination: IndexName,
                                    scope: Scope = .all,
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
   
   - Parameter source: IndexName of the source Index
   - Parameter destination: IndexName of the destination Index.
   - Parameter scope: Scope set. If empty (.all alias), then all objects and all scopes are copied.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: RevisionIndex  object
   */
  @discardableResult func copyIndex(from source: IndexName,
                                    to destination: IndexName,
                                    scope: Scope = .all,
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
  @discardableResult func moveIndex(from source: IndexName,
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
  @discardableResult func moveIndex(from source: IndexName,
                                    to destination: IndexName,
                                    requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<IndexRevision> {
    try index(withName: source).move(to: destination, requestOptions: requestOptions)
  }

  // MARK: - Copy rules

  /**
   Convenience method. Perform copyIndex with a specified Scope of .rules.
   
   - Parameter source: IndexName of the source Index
   - Parameter destination: IndexName of the destination Index.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func copyRules(from source: IndexName,
                                    to destination: IndexName,
                                    requestOptions: RequestOptions? = nil,
                                    completion: @escaping ResultTaskCallback<IndexRevision>) -> Operation & TransportTask {
    index(withName: source).copy(.rules, to: destination, requestOptions: requestOptions, completion: completion)
  }

  /**
   Convenience method. Perform copyIndex with a specified Scope of .rules.
   
   - Parameter source: IndexName of the source Index
   - Parameter destination: IndexName of the destination Index.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: RevisionIndex  object
   */
  @discardableResult func copyRules(from source: IndexName,
                                    to destination: IndexName,
                                    requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<IndexRevision> {
    try index(withName: source).copy(.rules, to: destination, requestOptions: requestOptions)
  }

  // MARK: - Copy synonyms

  /**
   Convenience method. Perform copyIndex with a specified Scope of .synonyms.
   
   - Parameter source: IndexName of the source Index
   - Parameter destination: IndexName of the destination Index.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func copySynonyms(from source: IndexName,
                                       to destination: IndexName,
                                       requestOptions: RequestOptions? = nil,
                                       completion: @escaping ResultTaskCallback<IndexRevision>) -> Operation & TransportTask {
    index(withName: source).copy(.synonyms, to: destination, requestOptions: requestOptions, completion: completion)
  }

  /**
   Convenience method. Perform copyIndex with a specified Scope of .synonyms.
   
   - Parameter source: IndexName of the source Index
   - Parameter destination: IndexName of the destination Index.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: RevisionIndex  object
   */
  @discardableResult func copySynonyms(from source: IndexName,
                                       to destination: IndexName,
                                       requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<IndexRevision> {
    try index(withName: source).copy(.synonyms, to: destination, requestOptions: requestOptions)
  }

  // MARK: - Copy settings

  /**
   Convenience method. Perform copyIndex with a specified Scope of .settings.
   
   - Parameter source: IndexName of the source Index
   - Parameter destination: IndexName of the destination Index.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func copySettings(from source: IndexName,
                                       to destination: IndexName,
                                       requestOptions: RequestOptions? = nil,
                                       completion: @escaping ResultTaskCallback<IndexRevision>) -> Operation & TransportTask {
    index(withName: source).copy(.settings, to: destination, requestOptions: requestOptions, completion: completion)
  }

  /**
   Convenience method. Perform copyIndex with a specified Scope of .settings.
   
   - Parameter source: IndexName of the source Index
   - Parameter destination: IndexName of the destination Index.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: RevisionIndex  object
   */
  @discardableResult func copySettings(from source: IndexName,
                                       to destination: IndexName,
                                       requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<IndexRevision> {
    try index(withName: source).copy(.settings, to: destination, requestOptions: requestOptions)
  }

}
