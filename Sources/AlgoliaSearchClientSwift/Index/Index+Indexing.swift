//
//  Index+Indexing.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

public extension Index {

  //MARK: - Save object
  
  /**
   Add a new record to an index.
   
   - Note: This method allows you to create records on your index by sending one or more objects.
   Each object contains a set of attributes and values, which represents a full record on an index.
   There is no limit to the number of objects that can be passed, but a size limit of 1 GB on the total request.
   For performance reasons, it is recommended to push batches of ~10 MB of payload.
   Batching records allows you to reduce the number of network calls required for multiple operations.
   But note that each indexed object counts as a single indexing operation.
   When adding large numbers of objects, or large sizes, be aware of our rate limit.
   You’ll know you’ve reached the rate limit when you start receiving errors on your indexing operations.
   This can only be resolved if you wait before sending any further indexing operations.
   - Parameter record: The record of type T to save.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Parameter completion: Result completion
   - Returns: Launched asynchronousoperation
   */
  @discardableResult func saveObject<T: Codable>(_ record: T, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<ObjectCreation>) -> Operation {
    let command = Command.Indexing.SaveObject(indexName: name,
                                              record: record,
                                              requestOptions: requestOptions)
    return performRequest(for: command, completion: completion)
  }
    
  /**
   Add a new record to an index.
   
   - See: saveObject
   - Parameter record: The record of type T to save.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Returns: ObjectCreation task
   */
  @discardableResult func saveObject<T: Codable>(_ record: T, requestOptions: RequestOptions? = nil) throws -> ObjectCreation {
    let command = Command.Indexing.SaveObject(indexName: name,
                                              record: record,
                                              requestOptions: requestOptions)
    return try performSyncRequest(for: command)
  }
    
  //MARK: - Save objects
  
  /**
   Add multiple schemaless objects to an index.
   
   - See: saveObject
   - Parameter records The list of records to save.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Parameter completion: Result completion
   - Returns: Launched asynchronousoperation
   */
  @discardableResult func saveObjects<T: Codable>(records: [T], requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<BatchResponse>) -> Operation {
    let operations = records.map { BatchOperation.add($0) }
    let command = Command.Index.Batch(indexName: name, batchOperations: operations, requestOptions: requestOptions)
    return performRequest(for: command, completion: completion)
  }
    
  /**
   Add multiple schemaless objects to an index.
   
   - See: saveObject
   - Parameter records The list of records to save.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Returns: Batch task
   */
  @discardableResult func saveObjects<T: Codable>(_ records: [T], requestOptions: RequestOptions? = nil) throws -> BatchResponse {
    let operations = records.map { BatchOperation.add($0) }
    let command = Command.Index.Batch(indexName: name, batchOperations: operations, requestOptions: requestOptions)
    return try performSyncRequest(for: command)
  }
  
  //MARK: - Get object

  /**
   Get one record using its ObjectID.
   
   - Parameter objectID: The ObjectID to identify the record.
   - Parameter attributesToRetrieve: Specify a list of Attribute to retrieve. This list will apply to all records. If you don’t specify any attributes, every attribute will be returned.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Parameter completion: Result completion
   - Returns: Launched asynchronousoperation
   */
  @discardableResult func getObject<T: Codable>(withID objectID: ObjectID, attributesToRetrieve: [Attribute] = [], requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<T>) -> Operation {
    let command = Command.Indexing.GetObject(indexName: name, objectID: objectID, attributesToRetrieve: attributesToRetrieve, requestOptions: requestOptions)
    return performRequest(for: command, completion: completion)
  }
    
  /**
   Get one record using its ObjectID.
   
   - Parameter objectID: The ObjectID to identify the record.
   - Parameter attributesToRetrieve: Specify a list of Attribute to retrieve. This list will apply to all records. If you don’t specify any attributes, every attribute will be returned.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Returns: Requested record
  */
  @discardableResult func getObject<T: Codable>(withID objectID: ObjectID, attributesToRetrieve: [Attribute] = [], requestOptions: RequestOptions? = nil) throws -> T {
    let command = Command.Indexing.GetObject(indexName: name, objectID: objectID, attributesToRetrieve: attributesToRetrieve, requestOptions: requestOptions)
    return try performSyncRequest(for: command)
  }
  
  //MARK: - Get objects
  
  /**
    Get multiple records using their ObjectID
   .
   - Parameter objectIDs: The list of ObjectID to identify the srecord.
   - Parameter attributesToRetrieve: Specify a list of Attribute to retrieve. This list will apply to all records. If you don’t specify any attributes, every attribute will be returned.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Parameter completion: Result completion
   - Returns: Launched asynchronousoperation
   */
  @discardableResult func getObjects<T: Codable>(withID objectIDs: [ObjectID], attributesToRetrieve: [Attribute] = [], requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<ObjectsResponse<T>>) -> Operation {
    let command = Command.Indexing.GetObjects(indexName: name, objectIDs: objectIDs, attributesToRetreive: attributesToRetrieve, requestOptions: requestOptions)
    return performRequest(for: command, completion: completion)
  }
  
  /**
    Get multiple records using their ObjectID.
   
   - Parameter objectIDs: The list ObjectID to identify the records.
   - Parameter attributesToRetrieve: Specify a list of Attribute to retrieve. This list will apply to all records. If you don’t specify any attributes, every attribute will be returned.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Parameter completion: Result completion
   - Returns: ObjectResponse object containing requested records
   */
  @discardableResult func getObjects<T: Codable>(withID objectIDs: [ObjectID], attributesToRetrieve: [Attribute] = [], requestOptions: RequestOptions? = nil) throws -> ObjectsResponse<T> {
    let command = Command.Indexing.GetObjects(indexName: name, objectIDs: objectIDs, attributesToRetreive: attributesToRetrieve, requestOptions: requestOptions)
    return try performSyncRequest(for: command)
  }
  
  //MARK: - Replace object
  
  /**
   Replace an existing object with an updated set of attributes.
   
   - Note: The save method is used to redefine the entire set of an object’s attributes (except of course its [ObjectID]).
   In other words, it fully replaces an existing object.
   Saving objects has the same effect as the add objects method if you specify objectIDs for every record.
   This method differs from partial update objects in a significant way:
   With save objects you define an object’s full set of attributes. Attributes not specified will no longer exist.
   For example, if an existing object contains attribute X, but X is not defined in a later update call, attribute X
   will no longer exist for that object.
   In contrast, with partial update objects you can single out one or more attributes, and either remove them,
   add them, or update their content. Additionally, attributes that already exist but are not specified in a partial update are not impacted.
   When updating large numbers of objects, or large sizes, be aware of our rate limit.
   You’ll know you’ve reached the rate limit when you start receiving errors on your indexing operations.
   This can only be resolved if you wait before sending any further indexing operations.
   - Parameter objectID: The ObjectID to identify the object.
   - Parameter record: The record T to replace.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func replaceObject<T: Codable>(withID objectID: ObjectID, by object: T, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<ObjectRevision>) -> Operation {
    let command = Command.Indexing.ReplaceObject(indexName: name, objectID: objectID, replacementObject: object, requestOptions: requestOptions)
    return performRequest(for: command, completion: completion)
  }
  
  /**
   Replace an existing object with an updated set of attributes.
   - seealso: replaceObject
   - Parameter objectID: The ObjectID to identify the object.
   - Parameter record: The record T to replace.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: ObjectRevision object
   */
  @discardableResult func replaceObject<T: Codable>(withID objectID: ObjectID, by object: T, requestOptions: RequestOptions? = nil) throws -> ObjectRevision {
    let command = Command.Indexing.ReplaceObject(indexName: name, objectID: objectID, replacementObject: object, requestOptions: requestOptions)
    return try performSyncRequest(for: command)
  }
  
  //MARK: - Replace objects

  /**
   Replace multiple objects with an updated set of attributes.
   
   - See: replaceObject
   - Parameter replacements: The list of paris of ObjectID and the replacement object .
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func replaceObjects<T: Codable>(replacements: [(objectID: ObjectID, object: T)], requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<ObjectRevision>) -> Operation {
    let operations: [BatchOperation] = replacements.map { (objectID, object) in .update(objectID: objectID, object) }
    let command = Command.Index.Batch(indexName: name, batchOperations: operations, requestOptions: requestOptions)
    return performRequest(for: command, completion: completion)
  }
  
  /**
   Replace multiple objects with an updated set of attributes.
   
   - See: replaceObject
   - Parameter replacements: The list of paris of ObjectID and the replacement object .
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: ObjectRevision object
   */
  @discardableResult func replaceObjects<T: Codable>(replacements: [(objectID: ObjectID, object: T)], requestOptions: RequestOptions? = nil) throws -> ObjectRevision {
    let operations: [BatchOperation] = replacements.map { (objectID, object) in .update(objectID: objectID, object) }
    let command = Command.Index.Batch(indexName: name, batchOperations: operations, requestOptions: requestOptions)
    return try performSyncRequest(for: command)
  }

  //MARK: - Delete object
  
  /**
   Remove an object from an index  using its ObjectID.
   
   - Parameter objectID: The ObjectID to identify the record.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Parameter completion: Result completion
   - Returns: Launched asynchronousoperation
   */
  @discardableResult func deleteObject<T: Codable>(withID objectID: ObjectID, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<T>) -> Operation {
    let command = Command.Indexing.DeleteObject(indexName: name, objectID: objectID, requestOptions: requestOptions)
    return performRequest(for: command, completion: completion)
  }
    
  /**
   Remove an object from an index using its ObjectID.
   
   - Parameter objectID: The ObjectID to identify the record.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Returns: Requested record
  */
  @discardableResult func deleteObject(withID objectID: ObjectID, requestOptions: RequestOptions? = nil) throws -> ObjectDeletion {
    let command = Command.Indexing.DeleteObject(indexName: name, objectID: objectID, requestOptions: requestOptions)
    return try performSyncRequest(for: command)
  }

  //MARK: - Delete objects
  
  /**
   Remove multiple objects from an index using their ObjectID.
   - Parameter objectIDs: The list ObjectID to identify the records.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func deleteObjects(withIDs objectIDs: [ObjectID], requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<BatchResponse>) -> Operation {
    let operations: [BatchOperation] = objectIDs.map { .delete(objectID: $0) }
    let command = Command.Index.Batch(indexName: name, batchOperations: operations, requestOptions: requestOptions)
    return performRequest(for: command, completion: completion)
  }

  /**
   Remove multiple objects from an index using their ObjectID.
   - Parameter objectIDs: The list ObjectID to identify the records.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: BatchResponse object
   */
  @discardableResult func deleteObjects(withIDs objectIDs: [ObjectID], requestOptions: RequestOptions? = nil) throws -> BatchResponse {
    let operations: [BatchOperation] = objectIDs.map { .delete(objectID: $0) }
    let command = Command.Index.Batch(indexName: name, batchOperations: operations, requestOptions: requestOptions)
    return try performSyncRequest(for: command)
  }
  
}

