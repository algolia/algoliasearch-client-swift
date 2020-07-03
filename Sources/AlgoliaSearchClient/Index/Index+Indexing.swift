//
//  Index+Indexing.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//
// swiftlint:disable file_length

import Foundation

public extension Index {

  // MARK: - Save object

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
   - Parameter object: The record of type T to save.
   - Parameter autoGeneratingObjectID: Add objectID if record type doesn't provide it in serialized form.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Parameter completion: Result completion
   - Returns: Launched asynchronousoperation
   */
  @discardableResult func saveObject<T: Encodable>(_ object: T,
                                                   autoGeneratingObjectID: Bool = false,
                                                   requestOptions: RequestOptions? = nil,
                                                   completion: @escaping ResultTaskCallback<ObjectCreation>) -> Operation & TransportTask {
    if !autoGeneratingObjectID {
      ObjectIDChecker.assertObjectID(object)
    }
    let command = Command.Indexing.SaveObject(indexName: name, record: object, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Add a new record to an index.
   
   - See: saveObject
   - Parameter object: The record of type T to save.
   - Parameter autoGeneratingObjectID: Add objectID if record type doesn't provide it in serialized form.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Returns: ObjectCreation task
   */
  @discardableResult func saveObject<T: Encodable>(_ object: T,
                                                   autoGeneratingObjectID: Bool = false,
                                                   requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<ObjectCreation> {
    if !autoGeneratingObjectID {
      try ObjectIDChecker.checkObjectID(object)
    }
    let command = Command.Indexing.SaveObject(indexName: name, record: object, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Save objects

  /**
   Add multiple schemaless objects to an index.
   
   - See: saveObject
   - Parameter objects The list of records to save.
   - Parameter autoGeneratingObjectID: Add objectID if record type doesn't provide it in serialized form.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Parameter completion: Result completion
   - Returns: Launched asynchronousoperation
   */
  @discardableResult func saveObjects<T: Encodable>(_ objects: [T],
                                                    autoGeneratingObjectID: Bool = false,
                                                    requestOptions: RequestOptions? = nil,
                                                    completion: @escaping ResultBatchesCallback) -> Operation {
    return batch(objects.map { .add($0, autoGeneratingObjectID: autoGeneratingObjectID) }, requestOptions: requestOptions, completion: completion)
  }

  /**
   Add multiple schemaless objects to an index.
   
   - See: saveObject
   - Parameter objects The list of records to save.
   - Parameter autoGeneratingObjectID: Add objectID if record type doesn't provide it in serialized form.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Returns: Batch task
   */
  @discardableResult func saveObjects<T: Encodable>(_ objects: [T],
                                                    autoGeneratingObjectID: Bool = false,
                                                    requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<BatchesResponse> {
    return try batch(objects.map { .add($0, autoGeneratingObjectID: autoGeneratingObjectID) }, requestOptions: requestOptions)
  }

  // MARK: - Get object

  /**
   Get one record using its ObjectID.
   
   - Parameter objectID: The ObjectID to identify the record.
   - Parameter attributesToRetrieve: Specify a list of Attribute to retrieve. This list will apply to all records. If you don’t specify any attributes, every attribute will be returned.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Parameter completion: Result completion
   - Returns: Launched asynchronousoperation
   */
  @discardableResult func getObject<T: Decodable>(withID objectID: ObjectID,
                                                  attributesToRetrieve: [Attribute] = [],
                                                  requestOptions: RequestOptions? = nil,
                                                  completion: @escaping ResultCallback<T>) -> Operation & TransportTask {
    let command = Command.Indexing.GetObject(indexName: name, objectID: objectID, attributesToRetrieve: attributesToRetrieve, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Get one record using its ObjectID.
   
   - Parameter objectID: The ObjectID to identify the record.
   - Parameter attributesToRetrieve: Specify a list of Attribute to retrieve. This list will apply to all records. If you don’t specify any attributes, every attribute will be returned.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Returns: Requested record
  */
  @discardableResult func getObject<T: Decodable>(withID objectID: ObjectID,
                                                  attributesToRetrieve: [Attribute] = [],
                                                  requestOptions: RequestOptions? = nil) throws -> T {
    let command = Command.Indexing.GetObject(indexName: name, objectID: objectID, attributesToRetrieve: attributesToRetrieve, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Get objects

  /**
    Get multiple records using their ObjectID.
   
   - Parameter objectIDs: The list of ObjectID to identify the srecord.
   - Parameter attributesToRetrieve: Specify a list of Attribute to retrieve. This list will apply to all records. If you don’t specify any attributes, every attribute will be returned.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Parameter completion: Result completion
   - Returns: Launched asynchronousoperation
   */
  @discardableResult func getObjects<T: Decodable>(withIDs objectIDs: [ObjectID],
                                                   attributesToRetrieve: [Attribute] = [],
                                                   requestOptions: RequestOptions? = nil,
                                                   completion: @escaping ResultCallback<ObjectsResponse<T>>) -> Operation & TransportTask {
    let command = Command.MultipleIndex.GetObjects(indexName: name, objectIDs: objectIDs, attributesToRetreive: attributesToRetrieve, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
    Get multiple records using their ObjectID.
   
   - Parameter objectIDs: The list ObjectID to identify the records.
   - Parameter attributesToRetrieve: Specify a list of Attribute to retrieve. This list will apply to all records. If you don’t specify any attributes, every attribute will be returned.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Parameter completion: Result completion
   - Returns: ObjectResponse object containing requested records
   */
  @discardableResult func getObjects<T: Decodable>(withIDs objectIDs: [ObjectID],
                                                   attributesToRetrieve: [Attribute] = [],
                                                   requestOptions: RequestOptions? = nil) throws -> ObjectsResponse<T> {
    let command = Command.MultipleIndex.GetObjects(indexName: name, objectIDs: objectIDs, attributesToRetreive: attributesToRetrieve, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Replace object

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
  @discardableResult func replaceObject<T: Encodable>(withID objectID: ObjectID,
                                                      by object: T,
                                                      requestOptions: RequestOptions? = nil,
                                                      completion: @escaping ResultTaskCallback<ObjectRevision>) -> Operation & TransportTask {
    let command = Command.Indexing.ReplaceObject(indexName: name, objectID: objectID, replacementObject: object, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Replace an existing object with an updated set of attributes.
   - See_also: replaceObject
   - Parameter objectID: The ObjectID to identify the object.
   - Parameter record: The record T to replace.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: ObjectRevision object
   */
  @discardableResult func replaceObject<T: Encodable>(withID objectID: ObjectID,
                                                      by object: T,
                                                      requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<ObjectRevision> {
    let command = Command.Indexing.ReplaceObject(indexName: name, objectID: objectID, replacementObject: object, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Replace objects

  /**
   Replace multiple objects with an updated set of attributes.
   
   - See: replaceObject
   - Parameter replacements: The list of paris of ObjectID and the replacement object .
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func replaceObjects<T: Encodable>(replacements: [(objectID: ObjectID, object: T)],
                                                       requestOptions: RequestOptions? = nil,
                                                       completion: @escaping ResultBatchesCallback) -> Operation {
    return batch(replacements.map { .update(objectID: $0.objectID, $0.object) }, requestOptions: requestOptions, completion: completion)
  }

  /**
   Replace multiple objects with an updated set of attributes.
   
   - See: replaceObject
   - Parameter replacements: The list of paris of ObjectID and the replacement object .
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: ObjectRevision object
   */
  @discardableResult func replaceObjects<T: Encodable>(replacements: [(objectID: ObjectID, object: T)],
                                                       requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<BatchesResponse> {
    return try batch(replacements.map { .update(objectID: $0.objectID, $0.object) }, requestOptions: requestOptions)
  }

  // MARK: - Delete object

  /**
   Remove an object from an index  using its ObjectID.
   
   - Parameter objectID: The ObjectID to identify the record.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Parameter completion: Result completion
   - Returns: Launched asynchronousoperation
   */
  @discardableResult func deleteObject(withID objectID: ObjectID,
                                       requestOptions: RequestOptions? = nil,
                                       completion: @escaping ResultTaskCallback<ObjectDeletion>) -> Operation & TransportTask {
    let command = Command.Indexing.DeleteObject(indexName: name, objectID: objectID, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Remove an object from an index using its ObjectID.
   
   - Parameter objectID: The ObjectID to identify the record.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Returns: Requested record
  */
  @discardableResult func deleteObject(withID objectID: ObjectID,
                                       requestOptions: RequestOptions? = nil) throws ->  WaitableWrapper<ObjectDeletion> {
    let command = Command.Indexing.DeleteObject(indexName: name, objectID: objectID, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Delete objects

  /**
   Remove multiple objects from an index using their ObjectID.
   - Parameter objectIDs: The list ObjectID to identify the records.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func deleteObjects(withIDs objectIDs: [ObjectID],
                                        requestOptions: RequestOptions? = nil,
                                        completion: @escaping ResultBatchesCallback) -> Operation {
    return batch(objectIDs.map { .delete(objectID: $0) }, requestOptions: requestOptions, completion: completion)
  }

  /**
   Remove multiple objects from an index using their ObjectID.
   - Parameter objectIDs: The list ObjectID to identify the records.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: BatchResponse object
   */
  @discardableResult func deleteObjects(withIDs objectIDs: [ObjectID],
                                        requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<BatchesResponse> {
    return try batch(objectIDs.map { .delete(objectID: $0) }, requestOptions: requestOptions)
  }

  /**
    Remove all objects matching a DeleteByQuery.
    
   - Note: This method enables you to delete one or more objects based on filters (numeric, facet, tag or geo queries).
   It does not accept empty filters or a query.
   If you have a way to fetch the list of ObjectID you want to delete, use the deleteObjects method instead as it is more performant.
   The delete by method only counts as 1 operation - even if it deletes more than one object.
   This is exceptional; most indexing options that affect more than one object normally count each object as a separate operation.
   When deleting large numbers of objects, or large sizes, be aware of our rate limit. You’ll know you’ve reached
   the rate limit when you start receiving errors on your indexing operations.
   This can only be resolved if you wait before sending any further indexing operations.
   
   - Parameter query: DeleteByQuery to match records for deletion.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func deleteObjects(byQuery query: DeleteByQuery,
                                        requestOptions: RequestOptions? = nil,
                                        completion: @escaping ResultTaskCallback<IndexRevision>) -> Operation & TransportTask {
    let command = Command.Indexing.DeleteByQuery(indexName: name, query: query, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
    Remove all objects matching a DeleteByQuery.
   
   - Parameter query: DeleteByQuery to match records for deletion.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Returns: RevisionIndex object
   */
  @discardableResult func deleteObjects(byQuery query: DeleteByQuery,
                                        requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<IndexRevision> {
    let command = Command.Indexing.DeleteByQuery(indexName: name, query: query, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Partial update object

  /**
   Update one or more attributes of an existing record.
   
   - Note: This method enables you to update only a part of an object by singling out one or more attributes of an existing
   object and performing the following actions:
   - add new attributes
   - update the content of existing attributes
   
   Specifying existing attributes will update them in the object, while specifying new attributes will add them.
   You need to use the save objects method if you want to completely redefine an existing object, replace an object
   with a different one, or remove attributes. You cannot individually remove attributes.
   Nested attributes cannot be individually updated. If you specify a nested attribute, it will be treated as a
   replacement of its first-level ancestor.
   To change nested attributes, you will need to use the save object method. You can initially get the object’s data
   either from your own data or by using the get object method.
   The same can be said about array attributes: you cannot update individual elements of an array.
   If you have a record in which one attribute is an array, you will need to retrieve the record’s array,
   change the element(s) of the array, and then resend the full array using this method.
   When updating large numbers of objects, or large sizes, be aware of our rate limit.
   You’ll know you’ve reached the rate limit when you start receiving errors on your indexing operations.
   This can only be resolved if you wait before sending any further indexing operations.

   - Parameter objectID: The ObjectID identifying the record to partially update.
   - Parameter partialUpdate: PartialUpdate
   - Parameter createIfNotExists: When true, a partial update on a nonexistent record will create the record
   (generating the objectID and using the attributes as defined in the record). When false, a partial
   update on a nonexistent record will be ignored (but no error will be sent back).
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func partialUpdateObject(withID objectID: ObjectID,
                                              with partialUpdate: PartialUpdate,
                                              createIfNotExists: Bool = true,
                                              requestOptions: RequestOptions? = nil,
                                              completion: @escaping ResultTaskCallback<ObjectRevision>) -> Operation & TransportTask {
    let command = Command.Indexing.PartialUpdate(indexName: name, objectID: objectID, partialUpdate: partialUpdate, createIfNotExists: createIfNotExists, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Update one or more attributes of an existing record.
   
   - Parameter objectID: The ObjectID identifying the record to partially update.
   - Parameter partialUpdate: PartialUpdate
   - Parameter createIfNotExists: When true, a partial update on a nonexistent record will create the record
   (generating the objectID and using the attributes as defined in the record). When false, a partial
   update on a nonexistent record will be ignored (but no error will be sent back).
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Returns: ObjectRevision object
   */
  @discardableResult func partialUpdateObject(withID objectID: ObjectID,
                                              with partialUpdate: PartialUpdate,
                                              createIfNotExists: Bool = true,
                                              requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<ObjectRevision> {
    let command = Command.Indexing.PartialUpdate(indexName: name, objectID: objectID, partialUpdate: partialUpdate, createIfNotExists: createIfNotExists, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Partial update objects

  /**
   Update one or more attributes of existing records.

   - Parameter updates: The list of pairs of ObjectID identifying the record and its PartialUpdate.
   - Parameter createIfNotExists: When true, a partial update on a nonexistent record will create the record
   (generating the objectID and using the attributes as defined in the record). When false, a partial
   update on a nonexistent record will be ignored (but no error will be sent back).
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func partialUpdateObjects(updates: [(objectID: ObjectID, update: PartialUpdate)],
                                               createIfNotExists: Bool = true,
                                               requestOptions: RequestOptions? = nil,
                                               completion: @escaping ResultBatchesCallback) -> Operation {
    return batch(updates.map { .partialUpdate(objectID: $0.objectID, $0.update, createIfNotExists: createIfNotExists) }, requestOptions: requestOptions, completion: completion)
  }

  /**
   Update one or more attributes of existing records.

   - Parameter replacements: The list of pairs of ObjectID identifying the record and its PartialUpdate.
   - Parameter createIfNotExists: When true, a partial update on a nonexistent record will create the record
   (generating the objectID and using the attributes as defined in the record). When false, a partial
   update on a nonexistent record will be ignored (but no error will be sent back).
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Parameter completion: Result completion
   - Returns: BatchResponse object
   */
  @discardableResult func partialUpdateObjects(updates: [(objectID: ObjectID, update: PartialUpdate)],
                                               createIfNotExists: Bool = true,
                                               requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<BatchesResponse> {
    return try batch(updates.map { .partialUpdate(objectID: $0.objectID, $0.update, createIfNotExists: createIfNotExists) }, requestOptions: requestOptions)
  }

  // MARK: - Batch operations

  /**
   Perform several indexing operations in one API call.
   
   - Note: This method enables you to batch multiple different indexing operations in one API, like add or delete records
   potentially targeting multiple indices.
   
   - Parameter batchOperations: List of BatchOperation
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func batch(_ batchOperations: [BatchOperation],
                                requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<BatchesResponse> {
    let responses = try batchOperations.chunked(into: configuration.batchSize).map { try internalBatch($0) }
    let response = BatchesResponse(indexName: name, responses: responses)
    return .init(batchesResponse: response, index: self)

  }

  /**
   Perform several indexing operations in one API call.
   
   - Parameter batchOperations: List of BatchOperation
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Returns: BatchesResponse object
   */
  @discardableResult func batch(_ batchOperations: [BatchOperation],
                                requestOptions: RequestOptions? = nil,
                                completion: @escaping ResultCallback<WaitableWrapper<BatchesResponse>>) -> Operation {
    let operation = BlockOperation {
      completion(.init { try self.batch(batchOperations, requestOptions: requestOptions) })
    }
    return launch(operation)
  }

  // MARK: - Clear objects

  /**
   Clear the records of an index without affecting its settings.
 
   - Note: This method enables you to delete an index’s contents (records) without removing any settings, rules and synonyms.
   If you want to remove the entire index and not just its records, use the delete method instead.
   Clearing an index will have no impact on its Analytics data because you cannot clear an index’s analytics data.
   
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func clearObjects(requestOptions: RequestOptions? = nil,
                                       completion: @escaping ResultTaskCallback<IndexRevision>) -> Operation & TransportTask {
    let command = Command.Indexing.ClearObjects(indexName: name, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Clear the records of an index without affecting its settings.

   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Returns: RevisionIndex object
   */
  @discardableResult func clearObjects(requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<IndexRevision> {
    let command = Command.Indexing.ClearObjects(indexName: name, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Replace all objects

  /**
   Push a new set of objects and remove all previous ones. Settings, synonyms and query rules are untouched.
   Replace all objects in an index without any downtime.
   Internally, this method copies the existing index settings, synonyms and query rules and indexes all
   passed objects. Finally, the existing index is replaced by the temporary one.
   - Parameter objects: A list of replacement objects.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter safe: Whether to wait for indexing operations.
   - Parameter completion: Result completion
   */
  func replaceAllObjects<T: Encodable>(with objects: [T],
                                       autoGeneratingObjectID: Bool = false,
                                       safe: Bool = false,
                                       requestOptions: RequestOptions? = nil,
                                       completion: @escaping ResultCallback<[IndexedTask]>) {
    let moveOperations: [BatchOperation] = objects.map { .add($0, autoGeneratingObjectID: autoGeneratingObjectID) }
    let sourceIndexName = name
    let destinationIndexName = IndexName(rawValue: "\(name)_tmp_\(Int.random(in: 0...100000))")
    let destinationIndex = Index(name: destinationIndexName, transport: transport, operationLauncher: operationLauncher, configuration: configuration)

    func extract<V>(_ result: Result<V, Error>, process: (V) -> Void) {
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let value):
        process(value)
      }
    }

    copy([.settings, .rules, .synonyms], to: destinationIndexName) { extract($0) { copyTaskWrapper in
      destinationIndex.batch(moveOperations) { extract($0) { batchTaskWrapper in
        destinationIndex.move(to: sourceIndexName) { extract($0) { moveTaskWrapper in
          let tasks: [IndexedTask] = [
            .init(indexName: sourceIndexName, taskID: copyTaskWrapper.task.taskID),
            .init(indexName: destinationIndexName, taskID: moveTaskWrapper.task.taskID)
            ] + batchTaskWrapper.wrapped.tasks
          guard safe else {
            completion(.success(tasks))
            return
          }

          let client = SearchClient(appID: self.applicationID, apiKey: self.apiKey)
          let waitService = WaitService(client: client, taskIndex: tasks)
          WaitableWrapper(wrapped: tasks, waitService: waitService).wait { result in
            switch result {
            case .failure(let error):
              completion(.failure(error))
            case .success:
              completion(.success(tasks))
            }
          }
          }
        }
        }
      }
      }
    }
  }

  /**
   Push a new set of objects and remove all previous ones. Settings, synonyms and query rules are untouched.
   Replace all objects in an index without any downtime.
   Internally, this method copies the existing index settings, synonyms and query rules and indexes all
   passed objects. Finally, the existing index is replaced by the temporary one.
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: [TaskIndex]  object
   */
  @discardableResult func replaceAllObjects<T: Encodable>(with objects: [T],
                                                          autoGeneratingObjectID: Bool = false,
                                                          requestOptions: RequestOptions? = nil) throws -> [IndexedTask] {

    let moveOperations: [BatchOperation] = objects.map { .add($0, autoGeneratingObjectID: autoGeneratingObjectID) }
    let destinationIndexName = IndexName(rawValue: "\(name)_tmp_\(Int.random(in: 0...100000))")
    let destinationIndex = Index(name: destinationIndexName, transport: transport, operationLauncher: operationLauncher, configuration: configuration)
    let moveTasks = try destinationIndex.batch(moveOperations).wrapped.tasks
    return [
      .init(indexName: name, taskID: try copy([.settings, .rules, .synonyms], to: destinationIndexName).task.taskID),
      .init(indexName: destinationIndexName, taskID: try destinationIndex.move(to: name).task.taskID)
    ] + moveTasks

  }

}

extension Index {

  @discardableResult func internalBatch(_ batchOperations: [BatchOperation],
                                        requestOptions: RequestOptions? = nil,
                                        completion: @escaping ResultCallback<BatchResponse>) -> Operation & TransportTask {
    let command = Command.Index.Batch(indexName: name, batchOperations: batchOperations, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  @discardableResult func internalBatch(_ batchOperations: [BatchOperation],
                                        requestOptions: RequestOptions? = nil) throws -> BatchResponse {
    let command = Command.Index.Batch(indexName: name, batchOperations: batchOperations, requestOptions: requestOptions)
    return try execute(command)
  }

}
