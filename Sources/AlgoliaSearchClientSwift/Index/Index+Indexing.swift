//
//  Index+Indexing.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

extension Index: IndexingEndpoint {
  
  func saveObject<T: Codable>(record: T,
                              requestOptions: RequestOptions? = nil,
                              completion: @escaping ResultCallback<ObjectCreation>) {
    let endpoint = Request.Indexing.SaveObject(indexName: name,
                                               record: record,
                                               requestOptions: requestOptions)
    performRequest(for: endpoint, completion: completion)
  }
  
  func getObject<T: Codable>(objectID: ObjectID,
                             attributesToRetreive: [Attribute] = [],
                             requestOptions: RequestOptions? = nil,
                             completion: @escaping ResultCallback<T>) {
    let endpoint = Request.Indexing.GetObject(indexName: name,
                                              objectID: objectID,
                                              requestOptions: requestOptions)
    performRequest(for: endpoint, completion: completion)
  }
    
}

extension Optional where Wrapped == RequestOptions {
  
  func withParameters(_ parameters: @autoclosure () -> [HTTPParameterKey: String]) -> Optional<RequestOptions> {
    let parameters = parameters()
    guard !parameters.isEmpty else {
      return self
    }
    var mutableRequestOptions = self ?? RequestOptions()
    for (key, value) in parameters {
      mutableRequestOptions.setParameter(value, forKey: key)
    }
    
    return mutableRequestOptions
  }
  
}
