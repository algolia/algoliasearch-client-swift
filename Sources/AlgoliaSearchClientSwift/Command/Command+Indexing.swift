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

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init<T: Codable>(indexName: IndexName, record: T, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        urlRequest = .init(method: .post,
                           path: indexName.toPath(),
                           body: record.httpBody,
                           requestOptions: requestOptions)
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
        let path = indexName.toPath(withSuffix: "/\(objectID.rawValue)")
        urlRequest = .init(method: .get, path: path, requestOptions: requestOptions)
      }

    }
    
    struct GetObjects: AlgoliaCommand {
      
      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?
      
      init(indexName: IndexName, objectIDs: [ObjectID], attributesToRetreive: [Attribute]?, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let requests = objectIDs.map { ObjectRequest(indexName: indexName, objectID: $0, attributesToRetrieve: attributesToRetreive) }
        let body = FieldWrapper(requests: requests).httpBody
        let path = indexName.toPath(withSuffix:"/*/objects")
        urlRequest = .init(method: .post, path: path, body: body, requestOptions: requestOptions)
      }
      
    }
    
    struct ReplaceObject: AlgoliaCommand {
      
      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?
      
      init<T: Codable>(indexName: IndexName, objectID: ObjectID, replacementObject record: T, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = indexName.toPath(withSuffix: "/\(objectID.rawValue)")
        urlRequest = .init(method: .put, path: path, body: record.httpBody, requestOptions: requestOptions)
      }
      
    }
    
    struct DeleteObject: AlgoliaCommand {
      
      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?
      
      init(indexName: IndexName, objectID: ObjectID, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = indexName.toPath(withSuffix: "/\(objectID.rawValue)")
        urlRequest = .init(method: .delete, path: path, requestOptions: requestOptions)
      }
      
    }
    
    struct DeleteByQuery: AlgoliaCommand {
      
      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?
      
      init(indexName: IndexName, query: AlgoliaSearchClientSwift.DeleteByQuery, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = indexName.toPath(withSuffix: "/deleteByQuery")
        let body = FieldWrapper(params: query).httpBody
        urlRequest = .init(method: .post, path: path, body: body, requestOptions: requestOptions)
      }
      
    }
    
    struct PartialUpdate: AlgoliaCommand {
      
      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?
      
      init(indexName: IndexName, objectID: ObjectID, partialUpdate: AlgoliaSearchClientSwift.PartialUpdate, createIfNotExists: Bool?, requestOptions: RequestOptions?) {
        let requestOptions = requestOptions.updateOrCreate({
          guard let createIfNotExists = createIfNotExists else { return [:] }
          return [.createIfNotExists: String(createIfNotExists)]
          }() )
        self.requestOptions = requestOptions
        let path = indexName.toPath(withSuffix: "/\(objectID.rawValue)/partial")
        let body = partialUpdate.httpBody
        urlRequest = .init(method: .post, path: path, body: body, requestOptions: requestOptions)
      }
      
    }
    
    struct ClearObjects: AlgoliaCommand {
      
      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = indexName.toPath(withSuffix: "/clear")
        urlRequest = .init(method: .post, path: path, requestOptions: requestOptions)
      }
      
    }

  }

}
