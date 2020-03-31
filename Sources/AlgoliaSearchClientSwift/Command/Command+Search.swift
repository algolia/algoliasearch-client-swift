//
//  Command+Search.swift
//  
//
//  Created by Vladislav Fitc on 10.03.2020.
//

import Foundation

extension Command {

  enum Search {

    struct Search: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName,
           query: Query,
           requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = indexName.toPath(withSuffix: "/query")
        urlRequest = .init(method: .post,
                           path: path,
                           body: query.httpBody,
                           requestOptions: requestOptions)
      }

    }
    
    struct Browse: AlgoliaCommand {
      
      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?
      
      init(indexName: IndexName, query: Query, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = indexName.toPath(withSuffix: "/browse")
        urlRequest = .init(method: .post, path: path, body: query.httpBody, requestOptions: requestOptions)
      }
      
      init(indexName: IndexName, cursor: Cursor, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions.updateOrCreate([.cursor: cursor.rawValue])
        let path = indexName.toPath(withSuffix: "/browse")
        urlRequest = .init(method: .get, path: path, requestOptions: requestOptions)
      }
      
    }
    
    struct SearchForFacets: AlgoliaCommand {
      
      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?
      
      init(indexName: IndexName, attribute: Attribute, facetQuery: String, query: Query, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        var queryCopy = query
        queryCopy.customParameters = (queryCopy.customParameters ?? [:]).merging(["facetQuery": .init(facetQuery)]) { (_, new) in new }
        let body = FieldWrapper(params: queryCopy).httpBody
        let path = indexName.toPath(withSuffix: "/facets/\(attribute)/query")
        urlRequest = .init(method: .post, path: path, body: body, requestOptions: requestOptions)
      }
      
    }

  }

}
