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
    
    
    
    struct GetObject: AlgoliaCommand {
      
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

extension Command {
  enum Index {}
}

extension Command.Index {
  
  struct DeleteIndex: AlgoliaCommand {
    
    let callType: CallType = .write
    let urlRequest: URLRequest
    let requestOptions: RequestOptions?
    
    init(indexName: IndexName,
         requestOptions: RequestOptions?) {
      self.requestOptions = requestOptions
      let path = indexName.toPath()
      urlRequest = .init(method: .delete,
                         path: path,
                         requestOptions: requestOptions)
    }
    
  }
  
}
