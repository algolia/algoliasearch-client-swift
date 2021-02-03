//
//  SearchClient+Dictionaries.swift
//  
//
//  Created by Vladislav Fitc on 21/01/2021.
//

import Foundation

public extension SearchClient {

  // MARK: - Save dictionary entries

  /**
   Save dictionary entries
   
   - Parameter dictionary: Target dictionary
   - Parameter dictionaryEntries: List of dictionary entries
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func saveDictionaryEntries<D: CustomDictionary>(to dictionary: D.Type,
                                                                     dictionaryEntries: [D.Entry],
                                                                     requestOptions: RequestOptions? = nil,
                                                                     completion: @escaping ResultCallback<WaitableWrapper<DictionaryRevision>>) -> Operation where D.Entry: Encodable {
    let requests = dictionaryEntries.map(DictionaryRequest.add)
    let command = Command.Dictionaries.Batch(dictionary: D.self,
                                             requests: requests,
                                             clearExistingDictionaryEntries: false,
                                             requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Save dictionary entries
   
   - Parameter dictionary: Target dictionary
   - Parameter dictionaryEntries: List of dictionary entries
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Response object
   */
  @discardableResult func saveDictionaryEntries<D: CustomDictionary>(to dictionary: D.Type,
                                                                     dictionaryEntries: [D.Entry],
                                                                     requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<DictionaryRevision> where D.Entry: Encodable {
    let requests = dictionaryEntries.map(DictionaryRequest.add)
    let command = Command.Dictionaries.Batch(dictionary: D.self,
                                             requests: requests,
                                             clearExistingDictionaryEntries: false,
                                             requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Replace dictionary entries

  /**
   Replace dictionary entries
   
   - Parameter dictionary: Target dictionary
   - Parameter dictionaryEntries: List of dictionary entries
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func replaceDictionaryEntries<D: CustomDictionary>(in dictionary: D.Type,
                                                                        with dictionaryEntries: [D.Entry],
                                                                        requestOptions: RequestOptions? = nil,
                                                                        completion: @escaping ResultCallback<WaitableWrapper<DictionaryRevision>>) -> Operation where D.Entry: Encodable {
    let requests = dictionaryEntries.map(DictionaryRequest.add)
    let command = Command.Dictionaries.Batch(dictionary: D.self,
                                             requests: requests,
                                             clearExistingDictionaryEntries: true,
                                             requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Replace dictionary entries
   
   - Parameter dictionary: Target dictionary
   - Parameter dictionaryEntries: List of dictionary entries
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Response object
   */
  @discardableResult func replaceDictionaryEntries<D: CustomDictionary>(in dictionary: D.Type,
                                                                        with dictionaryEntries: [D.Entry],
                                                                        requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<DictionaryRevision> where D.Entry: Encodable {
    let requests = dictionaryEntries.map(DictionaryRequest.add)
    let command = Command.Dictionaries.Batch(dictionary: D.self,
                                             requests: requests,
                                             clearExistingDictionaryEntries: true,
                                             requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Delete dictionary entries

  /**
   Delete dictionary entries
   
   - Parameter dictionary: Target dictionary
   - Parameter objectIDs: IDs of the objects to delete
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */

  @discardableResult func deleteDictionaryEntries<D: CustomDictionary>(from dictionary: D.Type,
                                                                       withObjectIDs objectIDs: [ObjectID],
                                                                       requestOptions: RequestOptions? = nil,
                                                                       completion: @escaping ResultCallback<WaitableWrapper<DictionaryRevision>>) -> Operation where D.Entry: Encodable {
    let command = Command.Dictionaries.Batch(dictionary: D.self,
                                             requests: objectIDs.map(DictionaryRequest<D.Entry>.deleteEntry(withObjectID:)),
                                             clearExistingDictionaryEntries: false,
                                             requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Delete dictionary entries
   
   - Parameter dictionary: Target dictionary
   - Parameter objectIDs: IDs of the objects to delete
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Response object
   */
  @discardableResult func deleteDictionaryEntries<D: CustomDictionary>(from dictionary: D.Type,
                                                                       withObjectIDs objectIDs: [ObjectID],
                                                                       requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<DictionaryRevision> where D.Entry: Encodable {
    let command = Command.Dictionaries.Batch(dictionary: D.self,
                                             requests: objectIDs.map(DictionaryRequest<D.Entry>.deleteEntry(withObjectID:)),
                                             clearExistingDictionaryEntries: false,
                                             requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Clear dictionary entries

  /**
   Clear dictionary entries
   
   - Parameter dictionary: Target dictionary
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */

  @discardableResult func clearDictionaryEntries<D: CustomDictionary>(dictionary: D.Type,
                                                                      requestOptions: RequestOptions? = nil,
                                                                      completion: @escaping ResultCallback<WaitableWrapper<DictionaryRevision>>) -> Operation where D.Entry: Encodable {
    return replaceDictionaryEntries(in: D.self, with: [], requestOptions: requestOptions, completion: completion)
  }

  /**
   Clear dictionary entries
   
   - Parameter dictionary: Target dictionary
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Response object
   */
  @discardableResult func clearDictionaryEntries<D: CustomDictionary>(dictionary: D.Type,
                                                                      requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<DictionaryRevision> where D.Entry: Encodable {
    return try replaceDictionaryEntries(in: D.self, with: [], requestOptions: requestOptions)
  }

  // MARK: - Search dictionary entries

  /**
   Search dictionary entries
   
   - Parameter dictionary: Target dictionary
   - Parameter query: Search query
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func searchDictionaryEntries<D: CustomDictionary>(in dictionary: D.Type,
                                                                       query: DictionaryQuery,
                                                                       requestOptions: RequestOptions? = nil,
                                                                       completion: @escaping ResultCallback<DictionarySearchResponse<D.Entry>>) -> Operation where D.Entry: Decodable {
    let command = Command.Dictionaries.Search(dictionaryName: D.name,
                                              query: query,
                                              requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Search dictionary entries
   
   - Parameter dictionary: Target dictionary
   - Parameter query: Search query
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Response object
   */
  @discardableResult func searchDictionaryEntries<D: CustomDictionary>(in dictionary: D.Type,
                                                                       query: DictionaryQuery,
                                                                       requestOptions: RequestOptions? = nil) throws -> DictionarySearchResponse<D.Entry> where D.Entry: Decodable {
    let command = Command.Dictionaries.Search(dictionaryName: D.name,
                                              query: query,
                                              requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Set dictionary settings

  /**
   Set dictionary settings
   
   - Parameter settings: Dictionaries settings
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func setDictionarySettings(_ settings: DictionarySettings,
                                                requestOptions: RequestOptions? = nil,
                                                completion: @escaping ResultCallback<WaitableWrapper<AppRevision>>) -> Operation {
    let command = Command.Dictionaries.SetSettings(settings: settings,
                                                   requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Set dictionary settings
   
   - Parameter settings: Dictionaries settings
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Response object
   */
  @discardableResult func setDictionarySettings(_ settings: DictionarySettings,
                                                requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<AppRevision> {
    let command = Command.Dictionaries.SetSettings(settings: settings,
                                                   requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Get dictionary settings

  /**
   Get dictionary settings
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func getDictionarySettings(requestOptions: RequestOptions? = nil,
                                                completion: @escaping ResultCallback<DictionarySettings>) -> Operation {
    let command = Command.Dictionaries.GetSettings(requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Get dictionary settings
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Response object
   */
  @discardableResult func getDictionarySettings(requestOptions: RequestOptions? = nil) throws -> DictionarySettings {
    let command = Command.Dictionaries.GetSettings(requestOptions: requestOptions)
    return try execute(command)
  }

}
