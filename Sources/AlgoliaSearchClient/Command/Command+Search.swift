//
//  Command+Search.swift
//  
//
//  Created by Vladislav Fitc on 10.03.2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

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
        let path = .indexesV1 >>> .index(indexName) >>> IndexCompletion.query
        urlRequest = .init(method: .post, path: path, body: query.httpBody, requestOptions: self.requestOptions)
      }

    }

    struct Browse: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName, query: Query, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = .indexesV1 >>> .index(indexName) >>> IndexCompletion.browse
        urlRequest = .init(method: .post, path: path, body: query.httpBody, requestOptions: requestOptions)
      }

      init(indexName: IndexName, cursor: Cursor, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let body = CursorWrapper(cursor)
        let path = .indexesV1 >>> .index(indexName) >>> IndexCompletion.browse
        urlRequest = .init(method: .post, path: path, body: body.httpBody, requestOptions: self.requestOptions)
      }

    }

    struct SearchForFacets: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName, attribute: Attribute, facetQuery: String, query: Query?, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        var parameters = query?.customParameters ?? [:]
        parameters["facetQuery"] = .init(facetQuery)
        var effectiveQuery = query ?? .init()
        effectiveQuery.customParameters = parameters
        let body = ParamsWrapper(effectiveQuery.urlEncodedString).httpBody
        let path = .indexesV1 >>> .index(indexName) >>> IndexCompletion.searchFacets(for: attribute)
        urlRequest = .init(method: .post, path: path, body: body, requestOptions: self.requestOptions)
      }

    }

  }

}
