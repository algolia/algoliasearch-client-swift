//
//  Index+Search.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

extension Index {

  /**
   Method used for querying an index.
   The search query only allows for the retrieval of up to 1000 hits.
   If you need to retrieve more than 1000 hits (e.g. for SEO), you can either leverage
   the [Browse index](https://www.algolia.com/doc/api-reference/api-methods/browse/) method or increase
   the [paginationLimitedTo](https://www.algolia.com/doc/api-reference/api-parameters/paginationLimitedTo/) parameter.
   - parameter query: The Query used to search.
   - parameter requestOptions: Configure request locally with RequestOptions.
   */
  @discardableResult public func search(query: Query,
                                        requestOptions: RequestOptions? = nil,
                                        completion: @escaping ResultCallback<SearchResponse>) -> Operation {
    let command = Command.Search.Search(indexName: name,
                                        query: query,
                                        requestOptions: requestOptions)
    return launch(command, completion: completion)
  }

}

public extension Index {

  func search(query: Query, requestOptions: RequestOptions? = nil) throws -> SearchResponse {
    let command = Command.Search.Search(indexName: name, query: query, requestOptions: requestOptions)
    return try launch(command)
  }

}
