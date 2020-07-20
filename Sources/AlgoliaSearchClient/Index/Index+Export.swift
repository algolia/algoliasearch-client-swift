//
//  Index.swift
//  
//
//  Created by Vladislav Fitc on 02/07/2020.
//

import Foundation

public extension Index {

  /**
   Iterate over all objects in the index.
   
   - Parameter query: The Query used to search.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Launched asynchronous operation
   */
  @discardableResult func browseObjects(query: Query = Query(),
                                        requestOptions: RequestOptions? = nil,
                                        completion: @escaping ResultCallback<[SearchResponse]>) -> Operation {
    let operation = BlockOperation {
      completion(.init { try self.browseObjects(query: query, requestOptions: requestOptions) })
    }
    return operationLauncher.launch(operation)
  }

  /**
   Iterate over all objects in the index.
   
   - Parameter query: The Query used to search.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: [SearchResponse] object
   */
  @discardableResult func browseObjects(query: Query = Query(),
                                        requestOptions: RequestOptions? = nil) throws -> [SearchResponse] {
    var responses: [SearchResponse] = []
    let initial = try browse(query: query, requestOptions: requestOptions)
    var cursor: Cursor? = initial.cursor
    responses.append(initial)

    while let nextCursor = cursor {
      let response = try browse(cursor: nextCursor)
      responses.append(response)
      cursor = response.cursor
    }

    return responses
  }

  /**
   Iterate over all Synonym in the index.
   
   - Parameter query: The SynonymQuery used to search.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Launched asynchronous operation
   */
  @discardableResult func browseSynonyms(query: SynonymQuery = .init(),
                                         requestOptions: RequestOptions? = nil,
                                         completion: @escaping ResultCallback<[SynonymSearchResponse]>) -> Operation {
    let operation = BlockOperation {
      completion(.init { try self.browseSynonyms(query: query, requestOptions: requestOptions) })
    }
    return operationLauncher.launch(operation)

  }

  /**
   Iterate over all Synonym in the index.
   
   - Parameter query: The SynonymQuery used to search.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: [SynonymSearchResponse] object
   */
  @discardableResult func browseSynonyms(query: SynonymQuery = .init(),
                                         requestOptions: RequestOptions? = nil) throws -> [SynonymSearchResponse] {
    var responses: [SynonymSearchResponse] = []
    var page = 0
    var response = try searchSynonyms(query, requestOptions: requestOptions)
    while !response.hits.isEmpty {
      response = try searchSynonyms(query.set(\.page, to: page), requestOptions: requestOptions)
      responses.append(response)
      page += 1
    }
    return responses
  }

  /**
   Iterate over all Rule in the index.
   
   - Parameter query: The RuleQuery used to search.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Launched asynchronous operation
   */
  @discardableResult func browseRules(query: RuleQuery = .init(),
                                      requestOptions: RequestOptions? = nil,
                                      completion: @escaping ResultCallback<[RuleSearchResponse]>) -> Operation {
    let operation = BlockOperation {
      completion(.init { try self.browseRules(query: query, requestOptions: requestOptions) })
    }
    return operationLauncher.launch(operation)
  }

  /**
   Iterate over all Rule in the index.
   
   - Parameter query: The RuleQuery used to search.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: [RuleSearchResponse] object
   */
  @discardableResult func browseRules(query: RuleQuery = .init(),
                                      requestOptions: RequestOptions? = nil) throws -> [RuleSearchResponse] {
    var responses: [RuleSearchResponse] = []
    var page = 0
    var response = try searchRules(query, requestOptions: requestOptions)
    while !response.hits.isEmpty {
      response = try searchRules(query.set(\.page, to: page), requestOptions: requestOptions)
      responses.append(response)
      page += 1
    }
    return responses
  }

}
