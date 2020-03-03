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
    let path = name.toPath(withSuffix: "/query")
    let request = HTTPRequest(transport: transport,
                              method: .post,
                              callType: .read,
                              path: path,
                              body: query.httpBody,
                              requestOptions: requestOptions,
                              completion: completion)
    queue.addOperation(request)
  }
  
}
