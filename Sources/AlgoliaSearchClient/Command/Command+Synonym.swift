//
//  Command+Synonym.swift
//
//
//  Created by Vladislav Fitc on 11/05/2020.
//

import Foundation

extension Command {
  enum Synonym {
    struct Save: AlgoliaCommand {
      let method: HTTPMethod = .put
      let callType: CallType = .write
      let path: URL
      let body: Data?
      let requestOptions: RequestOptions?

      init(
        indexName: IndexName, synonym: AlgoliaSearchClient.Synonym, forwardToReplicas: Bool?,
        requestOptions: RequestOptions?
      ) {
        self.requestOptions =
          forwardToReplicas.flatMap {
            requestOptions.updateOrCreate([.forwardToReplicas: String($0)])
          } ?? requestOptions
        path = URL
          .indexesV1
          .appending(indexName)
          .appending(.synonyms)
          .appending(synonym.objectID)
        body = synonym.httpBody
      }
    }

    struct SaveList: AlgoliaCommand {
      let method: HTTPMethod = .post
      let callType: CallType = .write
      let path: URL
      let body: Data?
      let requestOptions: RequestOptions?

      init(
        indexName: IndexName, synonyms: [AlgoliaSearchClient.Synonym], forwardToReplicas: Bool?,
        clearExistingSynonyms: Bool?, requestOptions: RequestOptions?
      ) {
        var parameters: [HTTPParameterKey: String] = [:]
        forwardToReplicas.flatMap { parameters[.forwardToReplicas] = String($0) }
        clearExistingSynonyms.flatMap { parameters[.replaceExistingSynonyms] = String($0) }
        self.requestOptions = requestOptions.updateOrCreate(parameters)
        path = URL
          .indexesV1
          .appending(indexName)
          .appending(.synonyms)
          .appending(.batch)
        body = synonyms.httpBody
      }
    }

    struct Get: AlgoliaCommand {
      let method: HTTPMethod = .get
      let callType: CallType = .read
      let path: URL
      let requestOptions: RequestOptions?

      init(indexName: IndexName, objectID: ObjectID, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        path = URL
          .indexesV1
          .appending(indexName)
          .appending(.synonyms)
          .appending(objectID)
      }
    }

    struct Delete: AlgoliaCommand {
      let method: HTTPMethod = .delete
      let callType: CallType = .write
      let path: URL
      let requestOptions: RequestOptions?

      init(
        indexName: IndexName, objectID: ObjectID, forwardToReplicas: Bool?,
        requestOptions: RequestOptions?
      ) {
        self.requestOptions =
          forwardToReplicas.flatMap {
            requestOptions.updateOrCreate([.forwardToReplicas: String($0)])
          } ?? requestOptions
        path = URL
          .indexesV1
          .appending(indexName)
          .appending(.synonyms)
          .appending(objectID)
      }
    }

    struct Search: AlgoliaCommand {
      let method: HTTPMethod = .post
      let callType: CallType = .read
      let path: URL
      let body: Data?
      let requestOptions: RequestOptions?

      init(indexName: IndexName, query: SynonymQuery, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        path = URL
          .indexesV1
          .appending(indexName)
          .appending(.synonyms)
          .appending(.search)
        body = query.httpBody
      }
    }

    struct Clear: AlgoliaCommand {
      let method: HTTPMethod = .post
      let callType: CallType = .write
      let path: URL
      let requestOptions: RequestOptions?

      init(indexName: IndexName, forwardToReplicas: Bool?, requestOptions: RequestOptions?) {
        self.requestOptions =
          forwardToReplicas.flatMap {
            requestOptions.updateOrCreate([.forwardToReplicas: String($0)])
          } ?? requestOptions
        path = URL
          .indexesV1
          .appending(indexName)
          .appending(.synonyms)
          .appending(.clear)
      }
    }
  }
}
