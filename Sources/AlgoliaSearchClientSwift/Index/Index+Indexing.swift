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
    let request = HTTPRequest(transport: transport,
                              method: .post,
                              callType: .write,
                              path: name.toPath(),
                              body: record.httpBody,
                              requestOptions: requestOptions,
                              completion: completion)
    queue.addOperation(request)
  }
  
  func getObject<T: Codable>(objectID: ObjectID,
                             attributesToRetreive: [Attribute] = [],
                             requestOptions: RequestOptions? = nil,
                             completion: @escaping ResultCallback<T>) {
    let requestOptions = requestOptions.withParameters( {
      guard !attributesToRetreive.isEmpty else { return [:] }
      let attributesValue = attributesToRetreive.map { $0.rawValue }.joined(separator: ",")
      return [.attributesToRetreive: attributesValue]
    }() )

    let path = name.toPath(withSuffix: "/\(objectID.rawValue)")
    let request = HTTPRequest(transport: transport,
                              method: .get,
                              callType: .read,
                              path: path,
                              requestOptions: requestOptions,
                              completion: completion)
    queue.addOperation(request)
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
