//
//  Command+Indexing.swift
//  
//
//  Created by Vladislav Fitc on 10.03.2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Command {

  enum Indexing {

    struct SaveObject: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init<T: Encodable>(indexName: IndexName, record: T, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = .indexesV1 >>> IndexRoute.index(indexName)
        urlRequest = .init(method: .post, path: path, body: record.httpBody, requestOptions: self.requestOptions)
      }

    }

    struct GetObject: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName, objectID: ObjectID, attributesToRetrieve: [Attribute], requestOptions: RequestOptions?) {
        let requestOptions = requestOptions.updateOrCreate({
          guard !attributesToRetrieve.isEmpty else { return [:] }
          let attributesValue = attributesToRetrieve.map(\.rawValue).joined(separator: ",")
          return [.attributesToRetreive: attributesValue]
        }() )
        self.requestOptions = requestOptions
        let path = .indexesV1 >>> .index(indexName) >>> IndexCompletion.objectID(objectID)
        urlRequest = .init(method: .get, path: path, requestOptions: self.requestOptions)
      }

    }

    struct ReplaceObject: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init<T: Encodable>(indexName: IndexName, objectID: ObjectID, replacementObject record: T, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = .indexesV1 >>> .index(indexName) >>> IndexCompletion.objectID(objectID)
        urlRequest = .init(method: .put, path: path, body: record.httpBody, requestOptions: self.requestOptions)
      }

    }

    struct DeleteObject: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName, objectID: ObjectID, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = .indexesV1 >>> .index(indexName) >>> IndexCompletion.objectID(objectID)
        urlRequest = .init(method: .delete, path: path, requestOptions: self.requestOptions)
      }

    }

    struct DeleteByQuery: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName, query: AlgoliaSearchClient.DeleteByQuery, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = .indexesV1 >>> .index(indexName) >>> IndexCompletion.deleteByQuery
        let body = ParamsWrapper(query.urlEncodedString).httpBody
        urlRequest = .init(method: .post, path: path, body: body, requestOptions: self.requestOptions)
      }

    }

    struct PartialUpdate: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName, objectID: ObjectID, partialUpdate: AlgoliaSearchClient.PartialUpdate, createIfNotExists: Bool?, requestOptions: RequestOptions?) {
        let requestOptions = requestOptions.updateOrCreate({
          guard let createIfNotExists = createIfNotExists else { return [:] }
          return [.createIfNotExists: String(createIfNotExists)]
          }() )
        self.requestOptions = requestOptions
        let path = .indexesV1 >>> .index(indexName) >>> IndexCompletion.objectID(objectID, partial: true)
        let body = partialUpdate.httpBody
        urlRequest = .init(method: .post, path: path, body: body, requestOptions: self.requestOptions)
      }

    }

    struct ClearObjects: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = .indexesV1 >>> .index(indexName) >>> IndexCompletion.clear
        urlRequest = .init(method: .post, path: path, requestOptions: self.requestOptions)
      }

    }

  }

}
