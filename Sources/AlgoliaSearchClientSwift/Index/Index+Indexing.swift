//
//  Index+Indexing.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

extension Index {

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
  @discardableResult public func saveObject<T: Codable>(record: T,
                                                        requestOptions: RequestOptions? = nil,
                                                        completion: @escaping ResultCallback<ObjectCreation>) -> Operation {
    let command = Command.Indexing.SaveObject(indexName: name,
                                              record: record,
                                              requestOptions: requestOptions)
    return performRequest(for: command, completion: completion)
  }

  public func saveObjects<T: Codable>(records: [T],
                                      requestOptions: RequestOptions? = nil,
                                      completion: @escaping ResultCallback<BatchResponse>) -> Operation {
    let operations = records.map { BatchOperation(action: .addObject, body: $0) }
    let command = Command.Index.Batch(indexName: name, batchOperations: operations, requestOptions: requestOptions)
    return performRequest(for: command, completion: completion)
  }

  /**
   * Get one record using its ObjectID.
   *
   * - parameter objectID: The ObjectID to identify the record.
   * - parameter attributesToRetrieve: Specify a list of Attribute to retrieve. This list will apply to all records.
   * If you don’t specify any attributes, every attribute will be returned.
   * - parameter requestOptions: Configure request locally with RequestOptions.
   */
  @discardableResult public func getObject<T: Codable>(withID objectID: ObjectID,
                                                       attributesToRetreive: [Attribute] = [],
                                                       requestOptions: RequestOptions? = nil,
                                                       completion: @escaping ResultCallback<T>) -> Operation {
    let command = Command.Indexing.GetObject(indexName: name,
                                             objectID: objectID,
                                             requestOptions: requestOptions)
    return performRequest(for: command, completion: completion)
  }

}

public extension Index {

  func saveObject<T: Codable>(record: T, requestOptions: RequestOptions? = nil) throws -> ObjectCreation {
    let command = Command.Indexing.SaveObject(indexName: name,
                                              record: record,
                                              requestOptions: requestOptions)
    return try performSyncRequest(for: command)
  }

  func saveObjects<T: Codable>(records: [T], requestOptions: RequestOptions? = nil) throws -> BatchResponse {
    let operations = records.map { BatchOperation(action: .addObject, body: $0) }
    let command = Command.Index.Batch(indexName: name, batchOperations: operations, requestOptions: requestOptions)
    return try performSyncRequest(for: command)
  }

  func getObject<T: Codable>(withID objectID: ObjectID, attributesToRetreive: [Attribute] = [], requestOptions: RequestOptions? = nil) throws -> T {
    let command = Command.Indexing.GetObject(indexName: name,
                                             objectID: objectID,
                                             requestOptions: requestOptions)
    return try performSyncRequest(for: command)
  }

}
