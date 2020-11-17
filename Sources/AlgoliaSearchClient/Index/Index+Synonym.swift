//
//  Index+Synonym.swift
//  
//
//  Created by Vladislav Fitc on 11/05/2020.
//

import Foundation

public extension Index {

  // MARK: - Save synonym

  /**
   Create or update a single synonym on an index.
   Whether you create or update a synonym, you must specify a unique ObjectID.
   If the ObjectID is not found in the index, the method will automatically create a new synonym.
   
   - Parameter synonym: synonym to save.
   - Parameter forwardToReplicas: By default, this method applies only to the specified index.
     By making this true, the method will also send the synonym to all replicas.
     Thus, if you want to forward your synonyms to replicas you will need to specify that.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func saveSynonym(_ synonym: Synonym,
                                      forwardToReplicas: Bool? = nil,
                                      requestOptions: RequestOptions? = nil,
                                      completion: @escaping ResultCallback<SynonymRevision>) -> Operation {
    let command = Command.Synonym.Save(indexName: name, synonym: synonym, forwardToReplicas: forwardToReplicas, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Create or update a single synonym on an index.
   Whether you create or update a synonym, you must specify a unique ObjectID.
   If the ObjectID is not found in the index, the method will automatically create a new synonym.
   
   - Parameter synonym: synonym to save.
   - Parameter forwardToReplicas: By default, this method applies only to the specified index.
     By making this true, the method will also send the synonym to all replicas.
     Thus, if you want to forward your synonyms to replicas you will need to specify that.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: SynonymRevision object
   */
  @discardableResult func saveSynonym(_ synonym: Synonym,
                                      forwardToReplicas: Bool? = nil,
                                      requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<SynonymRevision> {
    let command = Command.Synonym.Save(indexName: name, synonym: synonym, forwardToReplicas: forwardToReplicas, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Save synonym list

  /**
   Create or update multiple synonym.
   This method enables you to create or update one or more synonym in a single call.
   You can also recreate your entire set of synonym by using the clearExistingSynonyms parameter.
   Note that each synonym object counts as a single indexing operation.
   
   - Parameter synonyms: List of synonym to save.
   - Parameter forwardToReplicas: By default, this method applies only to the specified index.
     By making this true, the method will also send the synonym to all replicas.
     Thus, if you want to forward your synonyms to replicas you will need to specify that.
   - Parameter replaceExistingSynonyms: Forces the engine to replace all synonyms, using an atomic save.
     Normally, to replace all synonyms on an index, you would first clear the synonyms, using clearAllSynonyms, and then create a new list.
     However, between the clear and the add, your index will have no synonyms.
     This is where clearExistingSynonyms comes into play.
     By adding this parameter, you do not need to use clearSynonyms, it’s done for you.
     This parameter tells the engine to delete all existing synonyms before recreating a new list from the synonyms listed in the current call.
     This is the only way to avoid having no synonyms, ensuring that your index will always provide a full list of synonyms to your end-users.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @available(*, deprecated, renamed: "saveSynonyms(_:forwardToReplicas:clearExistingSynonyms:requestOptions:completion:)")
  @discardableResult func saveSynonyms(_ synonyms: [Synonym],
                                       forwardToReplicas: Bool? = nil,
                                       replaceExistingSynonyms: Bool?,
                                       requestOptions: RequestOptions? = nil,
                                       completion: @escaping ResultCallback<IndexRevision>) -> Operation {
    let command = Command.Synonym.SaveList(indexName: name, synonyms: synonyms, forwardToReplicas: forwardToReplicas, clearExistingSynonyms: replaceExistingSynonyms, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Create or update multiple synonym.
   This method enables you to create or update one or more synonym in a single call.
   You can also recreate your entire set of synonym by using the clearExistingSynonyms parameter.
   Note that each synonym object counts as a single indexing operation.
   
   - Parameter synonyms: List of synonym to save.
   - Parameter forwardToReplicas: By default, this method applies only to the specified index.
     By making this true, the method will also send the synonym to all replicas.
     Thus, if you want to forward your synonyms to replicas you will need to specify that.
   - Parameter replaceExistingSynonyms: Forces the engine to replace all synonyms, using an atomic save.
     Normally, to replace all synonyms on an index, you would first clear the synonyms, using clearAllSynonyms, and then create a new list.
     However, between the clear and the add, your index will have no synonyms.
     This is where clearExistingSynonyms comes into play.
     By adding this parameter, you do not need to use clearSynonyms, it’s done for you.
     This parameter tells the engine to delete all existing synonyms before recreating a new list from the synonyms listed in the current call.
     This is the only way to avoid having no synonyms, ensuring that your index will always provide a full list of synonyms to your end-users.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: IndexRevision  object
   */
  @available(*, deprecated, renamed: "saveSynonyms(_:forwardToReplicas:clearExistingSynonyms:requestOptions:)")
  @discardableResult func saveSynonyms(_ synonyms: [Synonym],
                                       forwardToReplicas: Bool? = nil,
                                       replaceExistingSynonyms: Bool?,
                                       requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<IndexRevision> {
    let command = Command.Synonym.SaveList(indexName: name, synonyms: synonyms, forwardToReplicas: forwardToReplicas, clearExistingSynonyms: replaceExistingSynonyms, requestOptions: requestOptions)
    return try execute(command)
  }
  
  /**
   Create or update multiple synonym.
   This method enables you to create or update one or more synonym in a single call.
   You can also recreate your entire set of synonym by using the clearExistingSynonyms parameter.
   Note that each synonym object counts as a single indexing operation.
   
   - Parameter synonyms: List of synonym to save.
   - Parameter forwardToReplicas: By default, this method applies only to the specified index.
     By making this true, the method will also send the synonym to all replicas.
     Thus, if you want to forward your synonyms to replicas you will need to specify that.
   - Parameter clearExistingSynonyms: Forces the engine to replace all synonyms, using an atomic save.
     Normally, to replace all synonyms on an index, you would first clear the synonyms, using clearAllSynonyms, and then create a new list.
     However, between the clear and the add, your index will have no synonyms.
     This is where clearExistingSynonyms comes into play.
     By adding this parameter, you do not need to use clearSynonyms, it’s done for you.
     This parameter tells the engine to delete all existing synonyms before recreating a new list from the synonyms listed in the current call.
     This is the only way to avoid having no synonyms, ensuring that your index will always provide a full list of synonyms to your end-users.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func saveSynonyms(_ synonyms: [Synonym],
                                       forwardToReplicas: Bool? = nil,
                                       clearExistingSynonyms: Bool? = nil,
                                       requestOptions: RequestOptions? = nil,
                                       completion: @escaping ResultCallback<IndexRevision>) -> Operation {
    let command = Command.Synonym.SaveList(indexName: name, synonyms: synonyms, forwardToReplicas: forwardToReplicas, clearExistingSynonyms: clearExistingSynonyms, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Create or update multiple synonym.
   This method enables you to create or update one or more synonym in a single call.
   You can also recreate your entire set of synonym by using the clearExistingSynonyms parameter.
   Note that each synonym object counts as a single indexing operation.
   
   - Parameter synonyms: List of synonym to save.
   - Parameter forwardToReplicas: By default, this method applies only to the specified index.
     By making this true, the method will also send the synonym to all replicas.
     Thus, if you want to forward your synonyms to replicas you will need to specify that.
   - Parameter clearExistingSynonyms: Forces the engine to replace all synonyms, using an atomic save.
     Normally, to replace all synonyms on an index, you would first clear the synonyms, using clearAllSynonyms, and then create a new list.
     However, between the clear and the add, your index will have no synonyms.
     This is where clearExistingSynonyms comes into play.
     By adding this parameter, you do not need to use clearSynonyms, it’s done for you.
     This parameter tells the engine to delete all existing synonyms before recreating a new list from the synonyms listed in the current call.
     This is the only way to avoid having no synonyms, ensuring that your index will always provide a full list of synonyms to your end-users.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: IndexRevision  object
   */
  @discardableResult func saveSynonyms(_ synonyms: [Synonym],
                                       forwardToReplicas: Bool? = nil,
                                       clearExistingSynonyms: Bool? = nil,
                                       requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<IndexRevision> {
    let command = Command.Synonym.SaveList(indexName: name, synonyms: synonyms, forwardToReplicas: forwardToReplicas, clearExistingSynonyms: clearExistingSynonyms, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Get synonym

  /**
   Get a single synonym using its ObjectID.
   
   - Parameter objectID: ObjectID of the synonym to retrieve.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func getSynonym(withID objectID: ObjectID,
                                     requestOptions: RequestOptions? = nil,
                                     completion: @escaping ResultCallback<Synonym>) -> Operation {
    let command = Command.Synonym.Get(indexName: name, objectID: objectID, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Get a single synonym using its ObjectID.
   
   - Parameter objectID: ObjectID of the synonym to retrieve.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Synonym object
   */
  @discardableResult func getSynonym(withID objectID: ObjectID,
                                     requestOptions: RequestOptions? = nil) throws -> Synonym {
    let command = Command.Synonym.Get(indexName: name, objectID: objectID, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Delete synonym

  /**
   Remove a single synonym from an index using its ObjectID.

   - Parameter objectID: ObjectID of the synonym to delete.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func deleteSynonym(withID objectID: ObjectID,
                                        forwardToReplicas: Bool? = nil,
                                        requestOptions: RequestOptions? = nil,
                                        completion: @escaping ResultCallback<IndexDeletion>) -> Operation {
    let command = Command.Synonym.Delete(indexName: name, objectID: objectID, forwardToReplicas: forwardToReplicas, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Remove a single synonym from an index using its ObjectID.

   - Parameter objectID: ObjectID of the synonym to delete.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: IndexDeletion object
   */
  @discardableResult func deleteSynonym(withID objectID: ObjectID,
                                        forwardToReplicas: Bool? = nil,
                                        requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<IndexDeletion> {
    let command = Command.Synonym.Delete(indexName: name, objectID: objectID, forwardToReplicas: forwardToReplicas, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Search synonyms

  /**
   Get all synonym that match a SynonymQuery.

   - Parameter query: the SynonymQuery.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func searchSynonyms(_ query: SynonymQuery,
                                         requestOptions: RequestOptions? = nil,
                                         completion: @escaping ResultCallback<SynonymSearchResponse>) -> Operation {
    let command = Command.Synonym.Search(indexName: name, query: query, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Get all synonym that match a SynonymQuery.

   - Parameter query: the SynonymQuery.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: SynonymSearchResponse  object
   */
  @discardableResult func searchSynonyms(_ query: SynonymQuery,
                                         requestOptions: RequestOptions? = nil) throws -> SynonymSearchResponse {
    let command = Command.Synonym.Search(indexName: name, query: query, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Clear synonyms

  /**
   Remove all synonyms from an index. This is a convenience method to delete all synonyms at once.
   This Clear All method should not be used on a production index to push a new list of synonyms because it will
   result in a short down period during which the index would have no synonyms at all.
   Instead, use the saveSynonyms method (with clearExistingSynonyms set to true) to atomically replace all synonyms of an index with no down time.
   
   - Parameter forwardToReplicas: Also replace synonyms on replicas.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func clearSynonyms(forwardToReplicas: Bool? = nil,
                                        requestOptions: RequestOptions? = nil,
                                        completion: @escaping ResultCallback<IndexRevision>) -> Operation {
    let command = Command.Synonym.Clear(indexName: name, forwardToReplicas: forwardToReplicas, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Remove all synonyms from an index. This is a convenience method to delete all synonyms at once.
   This Clear All method should not be used on a production index to push a new list of synonyms because it will
   result in a short down period during which the index would have no synonyms at all.
   Instead, use the saveSynonyms method (with clearExistingSynonyms set to true) to atomically replace all synonyms of an index with no down time.
   
   - Parameter forwardToReplicas: Also replace synonyms on replicas.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: IndexRevision object
   */
  @discardableResult func clearSynonyms(forwardToReplicas: Bool? = nil,
                                        requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<IndexRevision> {
    let command = Command.Synonym.Clear(indexName: name, forwardToReplicas: forwardToReplicas, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Replace all synonyms

  /**
   Push a new set of synonym and erase all previous ones.
   This method, like .replaceAllObjects, guarantees zero downtime.
   All existing synonym are deleted and replaced with the new ones, in a single, atomic operation.
   
   - Parameter synonyms: A list of synonym.
   - Parameter forwardToReplicas: Also replace synonyms on replicas.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func replaceAllSynonyms(with synonyms: [Synonym],
                                             forwardToReplicas: Bool? = nil,
                                             requestOptions: RequestOptions? = nil,
                                             completion: @escaping ResultCallback<IndexRevision>) -> Operation {
    saveSynonyms(synonyms, forwardToReplicas: forwardToReplicas, clearExistingSynonyms: true, requestOptions: requestOptions, completion: completion)
  }

  /**
   Push a new set of synonym and erase all previous ones.
   This method, like .replaceAllObjects, guarantees zero downtime.
   All existing synonym are deleted and replaced with the new ones, in a single, atomic operation.
   
   - Parameter synonyms: A list of synonym.
   - Parameter forwardToReplicas: Also replace synonyms on replicas.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: IndexRevision  object
   */
  @discardableResult func replaceAllSynonyms(with synonyms: [Synonym],
                                             forwardToReplicas: Bool? = nil,
                                             requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<IndexRevision> {
    try saveSynonyms(synonyms, forwardToReplicas: forwardToReplicas, clearExistingSynonyms: true, requestOptions: requestOptions)
  }

}
