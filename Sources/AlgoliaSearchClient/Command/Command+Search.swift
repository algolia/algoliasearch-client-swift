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

      let method: HTTPMethod = .post
      let callType: CallType = .read
      let path: URL
      let body: Data?
      let requestOptions: RequestOptions?

      init(indexName: IndexName,
           query: Query,
           requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = URL
          .indexesV1
          .appending(indexName)
          .appending(.query)
        self.body = query.httpBody
      }

    }

    struct Browse: AlgoliaCommand {

      let method: HTTPMethod = .post
      let callType: CallType = .read
      let path: URL
      let body: Data?
      let requestOptions: RequestOptions?

      init(indexName: IndexName, query: Query, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = URL
          .indexesV1
          .appending(indexName)
          .appending(.browse)
        self.body = query.httpBody
      }

      init(indexName: IndexName, cursor: Cursor, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.body = CursorWrapper(cursor).httpBody
        self.path = URL
          .indexesV1
          .appending(indexName)
          .appending(.browse)
      }

    }

    struct SearchForFacets: AlgoliaCommand {

      let method: HTTPMethod = .post
      let callType: CallType = .read
      let path: URL
      let body: Data?
      let requestOptions: RequestOptions?

      init(indexName: IndexName, attribute: Attribute, facetQuery: String, query: Query?, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = URL
          .indexesV1
          .appending(indexName)
          .appending(.facets)
          .appending(attribute)
          .appending(.query)
        var parameters = query?.customParameters ?? [:]
        parameters["facetQuery"] = .init(facetQuery)
        var effectiveQuery = query ?? .init()
        effectiveQuery.customParameters = parameters
        self.body = ParamsWrapper(effectiveQuery.urlEncodedString).httpBody
      }

    }

  }

}
