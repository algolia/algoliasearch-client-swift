//
//  Index+Search.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

extension Index: SearchEndpoint {
  
  @discardableResult func search(query: Query,
                                 requestOptions: RequestOptions? = nil,
                                 completion: @escaping ResultCallback<SearchResponse>) -> Operation {
    let command = Command.Search.Search(indexName: name,
                                         query: query,
                                         requestOptions: requestOptions)
    return performRequest(for: command, completion: completion)
  }
  
}

extension Index {
  
  func search(query: Query, requestOptions: RequestOptions? = nil) throws -> SearchResponse {
    let command = Command.Search.Search(indexName: name, query: query, requestOptions: requestOptions)
    return try performSyncRequest(for: command)
  }
  
}
