//
//  Index+Answers.swift
//  
//
//  Created by Vladislav Fitc on 20/11/2020.
//

import Foundation

public extension Index {

  /**
   Returns answers that match the query.
   
   - Parameter query: The AnswersQuery used to search.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func findAnswers(for query: AnswersQuery,
                                      requestOptions: RequestOptions? = nil,
                                      completion: @escaping ResultCallback<SearchResponse>) -> Operation & TransportTask {
    let command = Command.Answers.Find(indexName: name, query: query, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Returns answers that match the query.
   
   - Parameter query: The AnswersQuery used to search.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Returns: SearchResponse object
   */
  @discardableResult func findAnswers(for query: AnswersQuery,
                                      requestOptions: RequestOptions? = nil) throws -> SearchResponse {
    let command = Command.Answers.Find(indexName: name, query: query, requestOptions: requestOptions)
    return try execute(command)
  }

}
