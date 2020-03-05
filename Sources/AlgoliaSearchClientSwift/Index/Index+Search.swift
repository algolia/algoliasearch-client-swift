//
//  Index+Search.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

extension Index: SearchEndpoint {
  
  func search(query: Query,
              requestOptions: RequestOptions? = nil,
              completion: @escaping ResultCallback<SearchResponse>) {
    let endpoint = Request.Search.Search(indexName: name,
                                         query: query,
                                         requestOptions: requestOptions)
    performRequest(for: endpoint, completion: completion)
  }
  
}
