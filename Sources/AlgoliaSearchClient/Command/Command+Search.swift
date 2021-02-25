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
      let path: IndexCompletion
      let body: Data?
      let requestOptions: RequestOptions?

      init(indexName: IndexName,
           query: Query,
           requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = (.indexesV1 >>> .index(indexName) >>> .query)
        self.body = query.httpBody
      }

    }

    struct Browse: AlgoliaCommand {

      let method: HTTPMethod = .post
      let callType: CallType = .read
      let path: IndexCompletion
      let body: Data?
      let requestOptions: RequestOptions?

      init(indexName: IndexName, query: Query, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = (.indexesV1 >>> .index(indexName) >>> .browse)
        self.body = query.httpBody
      }

      init(indexName: IndexName, cursor: Cursor, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.body = CursorWrapper(cursor).httpBody
        self.path = (.indexesV1 >>> .index(indexName) >>> .browse)
      }

    }

    struct SearchForFacets: AlgoliaCommand {

      let method: HTTPMethod = .post
      let callType: CallType = .read
      let path: IndexCompletion
      let body: Data?
      let requestOptions: RequestOptions?

      init(indexName: IndexName, attribute: Attribute, facetQuery: String, query: Query?, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = (.indexesV1 >>> .index(indexName) >>> .searchFacets(for: attribute))
        var parameters = query?.customParameters ?? [:]
        parameters["facetQuery"] = .init(facetQuery)
        var effectiveQuery = query ?? .init()
        effectiveQuery.customParameters = parameters
        self.body = ParamsWrapper(effectiveQuery.urlEncodedString).httpBody
      }

    }

  }

}
