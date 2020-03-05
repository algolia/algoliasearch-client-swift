//
//  File.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation

protocol IndexingEndpoint {
  
  /**
   * Add a new record to an index.
   * This method allows you to create records on your index by sending one or more objects.
   * Each object contains a set of attributes and values, which represents a full record on an index.
   * There is no limit to the number of objects that can be passed, but a size limit of 1 GB on the total request.
   * For performance reasons, it is recommended to push batches of ~10 MB of payload.
   * Batching records allows you to reduce the number of network calls required for multiple operations.
   * But note that each indexed object counts as a single indexing operation.
   * When adding large numbers of objects, or large sizes, be aware of our rate limit.
   * You’ll know you’ve reached the rate limit when you start receiving errors on your indexing operations.
   * This can only be resolved if you wait before sending any further indexing operations.
   *
   * - parameter record: The record of type T to save.
   * - parameter requestOptions: Configure request locally with RequestOptions.
   */
  func saveObject<T: Codable>(record: T,
                              requestOptions: RequestOptions?,
                              completion: @escaping ResultCallback<ObjectCreation>)
  
  
  /**
   * Get one record using its ObjectID.
   *
   * - parameter objectID: The ObjectID to identify the record.
   * - parameter attributesToRetrieve: Specify a list of Attribute to retrieve. This list will apply to all records.
   * If you don’t specify any attributes, every attribute will be returned.
   * - parameter requestOptions: Configure request locally with RequestOptions.
   */
  func getObject<T: Codable>(objectID: ObjectID,
                             attributesToRetreive: [Attribute],
                             requestOptions: RequestOptions?,
                             completion: @escaping ResultCallback<T>)
    
}

protocol AlgoliaRequest {
  
  var callType: CallType { get }
  var urlRequest: URLRequest { get }
  var requestOptions: RequestOptions? { get }
  
}

enum Request {
}

extension Request {
  
  enum Indexing {
    
    struct SaveObject: AlgoliaRequest {
      
      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?
      
      init<T: Codable>(indexName: IndexName,
                       record: T,
                       requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        urlRequest = .init(method: .post,
                           path: indexName.toPath(),
                           body: record.httpBody,
                           requestOptions: requestOptions)
      }
      
      init(indexName: IndexName,
           record: [String: Any],
           requestOptions: RequestOptions?) throws {
        self.requestOptions = requestOptions
        let body = try JSONSerialization.data(withJSONObject: record, options: [])
        urlRequest = .init(method: .post,
                           path: indexName.toPath(),
                           body: body,
                           requestOptions: requestOptions)
      }
      
    }
    
    struct GetObject: AlgoliaRequest {
      
      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName,
           objectID: ObjectID,
           attributesToRetreive: [Attribute] = [],
           requestOptions: RequestOptions?) {
        let requestOptions = requestOptions.withParameters( {
          guard !attributesToRetreive.isEmpty else { return [:] }
          let attributesValue = attributesToRetreive.map { $0.rawValue }.joined(separator: ",")
          return [.attributesToRetreive: attributesValue]
        }() )
        self.requestOptions = requestOptions
        let path = indexName.toPath(withSuffix: "/\(objectID.rawValue)")
        urlRequest = .init(method: .get,
                           path: path,
                           requestOptions: requestOptions)
      }
      
    }
    
  }
  
}


extension Request {
  
  enum Search {
    
    struct Search: AlgoliaRequest {
      
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
    
  }
  
}


extension Request {
  
  enum Settings {
    
    struct GetSettings: AlgoliaRequest {
      
      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName,
           requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = indexName.toPath(withSuffix: "/\(Route.settings)")
        urlRequest = .init(method: .get,
                           path: path,
                           requestOptions: requestOptions)
      }
      
    }
    
    struct SetSettings: AlgoliaRequest {
      
      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName,
           settings: AlgoliaSearchClientSwift.Settings,
           resetToDefault: [AlgoliaSearchClientSwift.Settings.Key],
           forwardToReplicas: Bool?,
           requestOptions: RequestOptions?) {
        let requestOptions = requestOptions.withParameters({
          guard let forwardToReplicas = forwardToReplicas else { return [:] }
          return [.forwardToReplicas: "\(forwardToReplicas)"]
        }())
        self.requestOptions = requestOptions
        let path = indexName.toPath(withSuffix: "\(Route.settings)")
        urlRequest = .init(method: .put,
                           path: path,
                           body: settings.httpBody,
                           requestOptions: requestOptions)
      }
      
    }
    
  }

}
