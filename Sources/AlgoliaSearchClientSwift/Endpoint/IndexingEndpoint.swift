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
  @discardableResult func saveObject<T: Codable>(record: T,
                                                 requestOptions: RequestOptions?,
                                                 completion: @escaping ResultCallback<ObjectCreation>) -> Operation
  
  
  /**
   * Get one record using its ObjectID.
   *
   * - parameter objectID: The ObjectID to identify the record.
   * - parameter attributesToRetrieve: Specify a list of Attribute to retrieve. This list will apply to all records.
   * If you don’t specify any attributes, every attribute will be returned.
   * - parameter requestOptions: Configure request locally with RequestOptions.
   */
  @discardableResult func getObject<T: Codable>(objectID: ObjectID,
                                                attributesToRetreive: [Attribute],
                                                requestOptions: RequestOptions?,
                                                completion: @escaping ResultCallback<T>) -> Operation
    
}
