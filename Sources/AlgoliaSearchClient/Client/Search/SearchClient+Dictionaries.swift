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
   
   - Parameter dictionaryEntries: List of dictionary entries
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func saveDictionaryEntries<E: DictionaryEntry & Encodable>(_ dictionaryEntries: [E],
                                                                                requestOptions: RequestOptions? = nil,
                                                                                completion: @escaping ResultCallback<DictionaryRevision>) -> Operation {
    let requests = dictionaryEntries.map(DictionaryRequest.add)
    let command = Command.Dictionaries.Batch(requests: requests,
                                             clearExistingDictionaryEntries: false,
                                             requestOptions: requestOptions)
    return execute(command, completion: completion)
  }
  
  /**
   Save dictionary entries
   
   - Parameter dictionaryEntries: List of dictionary entries
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Response object
   */
  @discardableResult func saveDictionaryEntries<E: DictionaryEntry & Encodable>(_ dictionaryEntries: [E],
                                                                                requestOptions: RequestOptions? = nil) throws -> DictionaryRevision {
    let requests = dictionaryEntries.map(DictionaryRequest.add)
    let command = Command.Dictionaries.Batch(requests: requests,
                                             clearExistingDictionaryEntries: false,
                                             requestOptions: requestOptions)
    return try execute(command)
  }
  
  // MARK: - Replace dictionary entries
  
  /**
   Replace dictionary entries
   
   - Parameter dictionaryEntries: List of dictionary entries
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func replaceDictionaryEntries<E: DictionaryEntry & Encodable>(with dictionaryEntries: [E],
                                                                                   requestOptions: RequestOptions? = nil,
                                                   completion: @escaping ResultCallback<DictionaryRevision>) -> Operation {
    let requests = dictionaryEntries.map(DictionaryRequest.add)
    let command = Command.Dictionaries.Batch(requests: requests,
                                             clearExistingDictionaryEntries: true,
                                             requestOptions: requestOptions)
    return execute(command, completion: completion)
  }
  
  /**
   Replace dictionary entries
   
   - Parameter dictionaryEntries: List of dictionary entries
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Response object
   */
  @discardableResult func replaceDictionaryEntries<E: DictionaryEntry & Encodable>(with dictionaryEntries: [E],
                                                                                   requestOptions: RequestOptions? = nil) throws -> DictionaryRevision {
    let requests = dictionaryEntries.map(DictionaryRequest.add)
    let command = Command.Dictionaries.Batch(requests: requests,
                                             clearExistingDictionaryEntries: true,
                                             requestOptions: requestOptions)
    return try execute(command)
  }
  
  // MARK: - Delete dictionary entries
  
  /**
   Delete dictionary entries
   
   - Parameter dictionaryName: Name of the dictionary
   - Parameter objectIDs: IDs of the objects to delete
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func deleteDictionaryEntries(dictionaryName: DictionaryName,
                                                  withObjectIDs objectIDs: [ObjectID],
                                                  requestOptions: RequestOptions? = nil,
                                                  completion: @escaping ResultCallback<DictionaryRevision>) -> Operation {
    func deleteEntries<E: DictionaryEntry & Encodable>(of type: E.Type) -> Operation {
      let command = Command.Dictionaries.Batch(requests: objectIDs.map(DictionaryRequest<E>.deleteEntry(withObjectID:)),
                                               clearExistingDictionaryEntries: false,
                                               requestOptions: requestOptions)
      return execute(command, completion: completion)
    }
        
    switch dictionaryName {
    case .compounds:
      return deleteEntries(of: Compound.self)

    case .plurals:
      return deleteEntries(of: Plural.self)

    case .stopwords:
      return deleteEntries(of: StopWord.self)
    }
  }
  
  /**
   Delete dictionary entries
   
   - Parameter dictionaryName: Name of the dictionary
   - Parameter objectIDs: IDs of the objects to delete
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Response object
   */
  @discardableResult func deleteDictionaryEntries(dictionaryName: DictionaryName,
                                                  withObjectIDs objectIDs: [ObjectID],
                                                  requestOptions: RequestOptions? = nil) throws -> DictionaryRevision {
    func deleteEntries<E: DictionaryEntry & Encodable>(of type: E.Type) throws -> DictionaryRevision {
      let command = Command.Dictionaries.Batch(requests: objectIDs.map(DictionaryRequest<E>.deleteEntry(withObjectID:)),
                                               clearExistingDictionaryEntries: false,
                                               requestOptions: requestOptions)
      return try execute(command)
    }
    
    switch dictionaryName {
    case .compounds:
      return try deleteEntries(of: Compound.self)

    case .plurals:
      return try deleteEntries(of: Plural.self)

    case .stopwords:
      return try deleteEntries(of: StopWord.self)
    }
  }
  
  // MARK: - Clear dictionary entries
  
  /**
   Clear dictionary entries
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func clearDictionaryEntries(dictionaryName: DictionaryName,
                                                 requestOptions: RequestOptions? = nil,
                                                 completion: @escaping ResultCallback<DictionaryRevision>) -> Operation {
    func clearDictionary<E: DictionaryEntry & Encodable>(of type: E.Type) -> Operation {
      return replaceDictionaryEntries(with: [E](), requestOptions: requestOptions, completion: completion)
    }
    switch dictionaryName {
    case .compounds:
      return clearDictionary(of: Compound.self)
    case .plurals:
      return clearDictionary(of: Plural.self)
    case .stopwords:
      return clearDictionary(of: StopWord.self)
    }
  }
  
  /**
   Clear dictionary entries
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Response object
   */
  @discardableResult func clearDictionaryEntries(dictionaryName: DictionaryName,
                                                 requestOptions: RequestOptions? = nil) throws -> DictionaryRevision {
    func clearDictionary<E: DictionaryEntry & Encodable>(of type: E.Type) throws -> DictionaryRevision {
      return try replaceDictionaryEntries(with: [E](), requestOptions: requestOptions)
    }
    switch dictionaryName {
    case .compounds:
      return try clearDictionary(of: Compound.self)
    case .plurals:
      return try clearDictionary(of: Plural.self)
    case .stopwords:
      return try clearDictionary(of: StopWord.self)
    }
  }
  
  // MARK: - Search dictionary entries
  
  /**
   Search dictionary entries
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func searchDictionaryEntries<E: DictionaryEntry & Decodable>(dictionaryName: DictionaryName,
                                                                                  query: DictionaryQuery,
                                                                                  requestOptions: RequestOptions? = nil,
                                                                                  completion: @escaping ResultCallback<DictionarySearchResponse<E>>) -> Operation {
    let command = Command.Dictionaries.Search(dictionaryName: dictionaryName,
                                              query: query,
                                              requestOptions: requestOptions)
    return execute(command, completion: completion)
  }
  
  /**
   Search dictionary entries
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Response object
   */
  @discardableResult func searchDictionaryEntries<E: DictionaryEntry & Decodable>(dictionaryName: DictionaryName,
                                                                                  query: DictionaryQuery,
                                                                                  requestOptions: RequestOptions? = nil) throws -> DictionarySearchResponse<E> {
    let command = Command.Dictionaries.Search(dictionaryName: dictionaryName,
                                              query: query,
                                              requestOptions: requestOptions)
    return try execute(command)
  }
  
  // MARK: - Set dictionary settings
  
  /**
   Set dictionary settings
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func setDictionarySettings(_ settings: DictionarySettings,
                                                requestOptions: RequestOptions? = nil,
                                                completion: @escaping ResultCallback<Revision>) -> Operation {
    let command = Command.Dictionaries.SetSettings(settings: settings,
                                                   requestOptions: requestOptions)
    return execute(command, completion: completion)
  }
  
  /**
   Set dictionary settings
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Response object
   */
  @discardableResult func setDictionarySettings(_ settings: DictionarySettings,
                                                requestOptions: RequestOptions? = nil) throws -> Revision {
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
