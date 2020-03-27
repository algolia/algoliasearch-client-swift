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
        let requestOptions = requestOptions.withParameters({
          guard !attributesToRetrieve.isEmpty else { return [:] }
          let attributesValue = attributesToRetrieve.map(\.rawValue).joined(separator: ",")
          return [.attributesToRetreive: attributesValue]
        }() )
        self.requestOptions = requestOptions
        let path = indexName.toPath(withSuffix: "/\(objectID.rawValue)")
        urlRequest = .init(method: .get, path: path, requestOptions: requestOptions)
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
        let body = RequestParams(query).httpBody
        urlRequest = .init(method: .post, path: path, body: body, requestOptions: requestOptions)
      }
      
    }
    
    

  }

}

struct RequestParams<T: Codable>: Codable {
  
  let params: T
  
  init(_ content: T) {
    self.params = content
  }
  
}


