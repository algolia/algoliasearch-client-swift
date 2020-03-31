//
//  Index+Search.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

public extension Index {
  
  //MARK: - Search

  /**
   Method used for querying an index.
   
   - Note: The search query only allows for the retrieval of up to 1000 hits.
   If you need to retrieve more than 1000 hits (e.g. for SEO), you can either leverage
   the [Browse index](https://www.algolia.com/doc/api-reference/api-methods/browse/) method or increase
   the [paginationLimitedTo](https://www.algolia.com/doc/api-reference/api-parameters/paginationLimitedTo/) parameter.
   - Parameter query: The Query used to search.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func search(query: Query, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<SearchResponse>) -> Operation {
    let command = Command.Search.Search(indexName: name, query: query, requestOptions: requestOptions)
    return launch(command, completion: completion)
  }
  
  /**
   Method used for querying an index.

   - Parameter query: The Query used to search.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Parameter completion: Result completion
   - Returns: SearchResponse object
   */
  @discardableResult func search(query: Query, requestOptions: RequestOptions? = nil) throws -> SearchResponse {
    let command = Command.Search.Search(indexName: name, query: query, requestOptions: requestOptions)
    return try launch(command)
  }
  
  //MARK: - Browse
  
  /**
   Get all index content without any record limit. Can be used for backups.
   
   - Note: The browse method is an alternative to the Search index method.
   If you need to retrieve the full content of your index (for backup, SEO purposes or for running a script on it),
   you should use this method instead.
   Results are ranked by attributes and custom ranking.
   But for performance reasons, there is no ranking based on:
   - distinct
   - typo-tolerance
   - number of matched words
   - proximity
   - geo distance
  
   You shouldn’t use this method for building a search UI.
   The analytics API does not collect data from browse method usage.
   If you need to retrieve more than 1,000 results, you should look into the
   [paginationLimitedTo](https://www.algolia.com/doc/api-reference/api-parameters/paginationLimitedTo/) parameter.
  
   If more records are available, SearchResponse.cursor will not be null.
  
   - Parameter query: The Query used to search.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Parameter completion: Result completion
   - Returns: SearchResponse object
   */
  @discardableResult func browse(query: Query, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<SearchResponse>) -> Operation {
    let command = Command.Search.Browse(indexName: name, query: query, requestOptions: requestOptions)
    return launch(command, completion: completion)
  }
  
  /**
   Get all index content without any record limit. Can be used for backups.
   
   - Parameter query: The Query used to search.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func browse(query: Query, requestOptions: RequestOptions? = nil) throws -> SearchResponse {
    let command = Command.Search.Browse(indexName: name, query: query, requestOptions: requestOptions)
    return try launch(command)
  }
  
  /**
   Get all index content without any record limit. Can be used for backups.
   
   - Parameter cursor: Cursor indicating the location to resume browsing from.
   Must match the value returned by the previous call to browse SearchResponse.cursor
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func browse(cursor: Cursor, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<SearchResponse>) -> Operation {
    let command = Command.Search.Browse(indexName: name, cursor: cursor, requestOptions: requestOptions)
    return launch(command, completion: completion)
  }
  
  /**
   Get all index content without any record limit. Can be used for backups.
   
   - Parameter cursor: Cursor indicating the location to resume browsing from.
   Must match the value returned by the previous call to browse SearchResponse.cursor
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: SearchResponse object
   */
  @discardableResult func browse(cursor: Cursor, requestOptions: RequestOptions? = nil) throws -> SearchResponse {
    let command = Command.Search.Browse(indexName: name, cursor: cursor, requestOptions: requestOptions)
    return try launch(command)
  }
  
}
