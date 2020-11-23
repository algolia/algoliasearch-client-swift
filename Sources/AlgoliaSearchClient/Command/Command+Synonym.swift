//
//  Command+Synonym.swift
//  
//
//  Created by Vladislav Fitc on 11/05/2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Command {

  enum Synonym {

    struct Save: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName, synonym: AlgoliaSearchClient.Synonym, forwardToReplicas: Bool?, requestOptions: RequestOptions?) {
        self.requestOptions = forwardToReplicas.flatMap { requestOptions.updateOrCreate([.forwardToReplicas: String($0)]) } ?? requestOptions
        let path = .indexesV1 >>> .index(indexName) >>> .synonyms >>> SynonymCompletion.objectID(synonym.objectID)
        urlRequest = .init(method: .put, path: path, body: synonym.httpBody, requestOptions: self.requestOptions)
      }

    }

    struct SaveList: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName, synonyms: [AlgoliaSearchClient.Synonym], forwardToReplicas: Bool?, clearExistingSynonyms: Bool?, requestOptions: RequestOptions?) {
        var parameters: [HTTPParameterKey: String] = [:]
        forwardToReplicas.flatMap { parameters[.forwardToReplicas] = String($0) }
        clearExistingSynonyms.flatMap { parameters[.replaceExistingSynonyms] = String($0) }
        self.requestOptions = requestOptions.updateOrCreate(parameters)
        let path = .indexesV1 >>> .index(indexName) >>> .synonyms >>> SynonymCompletion.batch
        urlRequest = .init(method: .post, path: path, body: synonyms.httpBody, requestOptions: self.requestOptions)
      }

    }

    struct Get: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName, objectID: ObjectID, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = .indexesV1 >>> .index(indexName) >>> .synonyms >>> SynonymCompletion.objectID(objectID)
        urlRequest = .init(method: .get, path: path, requestOptions: self.requestOptions)
      }

    }

    struct Delete: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName, objectID: ObjectID, forwardToReplicas: Bool?, requestOptions: RequestOptions?) {
        self.requestOptions = forwardToReplicas.flatMap { requestOptions.updateOrCreate([.forwardToReplicas: String($0)]) } ?? requestOptions
        let path = .indexesV1 >>> .index(indexName) >>> .synonyms >>> SynonymCompletion.objectID(objectID)
        urlRequest = .init(method: .delete, path: path, requestOptions: self.requestOptions)
      }

    }

    struct Search: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName, query: SynonymQuery, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = .indexesV1 >>> .index(indexName) >>> .synonyms >>> SynonymCompletion.search
        urlRequest = .init(method: .post, path: path, body: query.httpBody, requestOptions: self.requestOptions)
      }

    }

    struct Clear: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName, forwardToReplicas: Bool?, requestOptions: RequestOptions?) {
        self.requestOptions = forwardToReplicas.flatMap { requestOptions.updateOrCreate([.forwardToReplicas: String($0)]) } ?? requestOptions
        let path = .indexesV1 >>> .index(indexName) >>> .synonyms >>> SynonymCompletion.clear
        urlRequest = .init(method: .post, path: path, requestOptions: self.requestOptions)
      }

    }

  }

}
