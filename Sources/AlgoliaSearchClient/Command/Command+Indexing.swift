//
//  Command+Indexing.swift
//  
//
//  Created by Vladislav Fitc on 10.03.2020.
//

import Foundation

extension Command {

  enum Indexing {

    struct SaveObject: AlgoliaCommand {

      let method: HTTPMethod = .post
      let callType: CallType = .write
      let path: IndexRoute
      let body: Data?
      let requestOptions: RequestOptions?

      init<T: Encodable>(indexName: IndexName, record: T, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = (.indexesV1 >>> .index(indexName))
        self.body = record.httpBody
      }

    }

    struct GetObject: AlgoliaCommand {

      let method: HTTPMethod = .get
      let callType: CallType = .read
      let path: IndexCompletion
      let requestOptions: RequestOptions?

      init(indexName: IndexName, objectID: ObjectID, attributesToRetrieve: [Attribute], requestOptions: RequestOptions?) {
        let requestOptions = requestOptions.updateOrCreate({
          guard !attributesToRetrieve.isEmpty else { return [:] }
          let attributesValue = attributesToRetrieve.map(\.rawValue).joined(separator: ",")
          return [.attributesToRetreive: attributesValue]
        }() )
        self.requestOptions = requestOptions
        self.path = (.indexesV1 >>> .index(indexName) >>> .objectID(objectID))
      }

    }

    struct ReplaceObject: AlgoliaCommand {

      let method: HTTPMethod = .put
      let callType: CallType = .write
      let path: IndexCompletion
      let body: Data?
      let requestOptions: RequestOptions?

      init<T: Encodable>(indexName: IndexName, objectID: ObjectID, replacementObject record: T, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = (.indexesV1 >>> .index(indexName) >>> .objectID(objectID))
        self.body = record.httpBody
      }

    }

    struct DeleteObject: AlgoliaCommand {

      let method: HTTPMethod = .delete
      let callType: CallType = .write
      let path: IndexCompletion
      let requestOptions: RequestOptions?

      init(indexName: IndexName, objectID: ObjectID, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = (.indexesV1 >>> .index(indexName) >>> .objectID(objectID))
      }

    }

    struct DeleteByQuery: AlgoliaCommand {

      let method: HTTPMethod = .post
      let callType: CallType = .write
      let path: IndexCompletion
      let body: Data?
      let requestOptions: RequestOptions?

      init(indexName: IndexName, query: AlgoliaSearchClient.DeleteByQuery, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = (.indexesV1 >>> .index(indexName) >>> .deleteByQuery)
        self.body = ParamsWrapper(query.urlEncodedString).httpBody
      }

    }

    struct PartialUpdate: AlgoliaCommand {

      let method: HTTPMethod = .post
      let callType: CallType = .write
      let path: IndexCompletion
      let body: Data?
      let requestOptions: RequestOptions?

      init(indexName: IndexName, objectID: ObjectID, partialUpdate: AlgoliaSearchClient.PartialUpdate, createIfNotExists: Bool?, requestOptions: RequestOptions?) {
        let requestOptions = requestOptions.updateOrCreate({
          guard let createIfNotExists = createIfNotExists else { return [:] }
          return [.createIfNotExists: String(createIfNotExists)]
          }() )
        self.requestOptions = requestOptions
        self.path = (.indexesV1 >>> .index(indexName) >>> .objectID(objectID, partial: true))
        self.body = partialUpdate.httpBody
      }

    }

    struct ClearObjects: AlgoliaCommand {

      let method: HTTPMethod = .post
      let callType: CallType = .write
      let path: IndexCompletion
      let requestOptions: RequestOptions?

      init(indexName: IndexName, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = (.indexesV1 >>> .index(indexName) >>> .clear)
      }

    }

  }

}
