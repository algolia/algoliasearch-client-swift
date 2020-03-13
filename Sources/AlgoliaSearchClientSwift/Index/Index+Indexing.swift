//
//  Index+Indexing.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

extension Index: IndexingEndpoint {
  
  @discardableResult public func saveObject<T: Codable>(record: T,
                                                 requestOptions: RequestOptions? = nil,
                                                 completion: @escaping ResultCallback<ObjectCreation>) -> Operation {
    let command = Command.Indexing.SaveObject(indexName: name,
                                               record: record,
                                               requestOptions: requestOptions)
    return performRequest(for: command, completion: completion)
  }
  
  
  @discardableResult public func getObject<T: Codable>(objectID: ObjectID,
                                                attributesToRetreive: [Attribute] = [],
                                                requestOptions: RequestOptions? = nil,
                                                completion: @escaping ResultCallback<T>) -> Operation {
    let command = Command.Indexing.GetObject(indexName: name,
                                              objectID: objectID,
                                              requestOptions: requestOptions)
    return performRequest(for: command, completion: completion)
  }
    
}

extension Index {
  
  func saveObject<T: Codable>(record: T, requestOptions: RequestOptions? = nil) throws -> ObjectCreation {
    let command = Command.Indexing.SaveObject(indexName: name,
                                               record: record,
                                               requestOptions: requestOptions)
    return try performSyncRequest(for: command)
  }

  func getObject<T: Codable>(objectID: ObjectID, attributesToRetreive: [Attribute] = [], requestOptions: RequestOptions? = nil) throws -> T {
    let command = Command.Indexing.GetObject(indexName: name,
                                              objectID: objectID,
                                              requestOptions: requestOptions)
    return try performSyncRequest(for: command)
  }
  
}


