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
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func saveDictionaryEntries(requestOptions: RequestOptions? = nil,
                                                completion: @escaping ResultCallback<String>) -> Operation {
    let command = Command.Template()
    return execute(command, completion: completion)
  }
  
  /**
   Save dictionary entries
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Response object
   */
  @discardableResult func saveDictionaryEntries(requestOptions: RequestOptions? = nil) throws -> String {
    let command = Command.Template()
    return try execute(command)
  }
  
  // MARK: - Replace dictionary entries
  
  /**
   Replace dictionary entries
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func replaceDictionaryEntries(requestOptions: RequestOptions? = nil,
                                                   completion: @escaping ResultCallback<String>) -> Operation {
    let command = Command.Template()
    return execute(command, completion: completion)
  }
  
  /**
   Replace dictionary entries
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Response object
   */
  @discardableResult func replaceDictionaryEntries(requestOptions: RequestOptions? = nil) throws -> String {
    let command = Command.Template()
    return try execute(command)
  }
  
  // MARK: - Delete dictionary entries
  
  /**
   Delete dictionary entries
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func deleteDictionaryEntries(requestOptions: RequestOptions? = nil,
                                                  completion: @escaping ResultCallback<String>) -> Operation {
    let command = Command.Template()
    return execute(command, completion: completion)
  }
  
  /**
   Delete dictionary entries
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Response object
   */
  @discardableResult func deleteDictionaryEntries(requestOptions: RequestOptions? = nil) throws -> String {
    let command = Command.Template()
    return try execute(command)
  }
  
  // MARK: - Clear dictionary entries
  
  /**
   Clear dictionary entries
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func clearDictionaryEntries(requestOptions: RequestOptions? = nil,
                                                 completion: @escaping ResultCallback<String>) -> Operation {
    let command = Command.Template()
    return execute(command, completion: completion)
  }
  
  /**
   Clear dictionary entries
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Response object
   */
  @discardableResult func clearDictionaryEntries(requestOptions: RequestOptions? = nil) throws -> String {
    let command = Command.Template()
    return try execute(command)
  }
  
  // MARK: - Search dictionary entries
  
  /**
   Search dictionary entries
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func searchDictionaryEntries(requestOptions: RequestOptions? = nil,
                                                  completion: @escaping ResultCallback<String>) -> Operation {
    let command = Command.Template()
    return execute(command, completion: completion)
  }
  
  /**
   Search dictionary entries
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Response object
   */
  @discardableResult func searchDictionaryEntries(requestOptions: RequestOptions? = nil) throws -> String {
    let command = Command.Template()
    return try execute(command)
  }
  
  // MARK: - Set dictionary settings
  
  /**
   Set dictionary settings
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func setDictionarySettings(requestOptions: RequestOptions? = nil,
                                                completion: @escaping ResultCallback<String>) -> Operation {
    let command = Command.Template()
    return execute(command, completion: completion)
  }
  
  /**
   Set dictionary settings
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Response object
   */
  @discardableResult func setDictionarySettings(requestOptions: RequestOptions? = nil) throws -> String {
    let command = Command.Template()
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
                                                completion: @escaping ResultCallback<String>) -> Operation {
    let command = Command.Template()
    return execute(command, completion: completion)
  }
  
  /**
   Get dictionary settings
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Response object
   */
  @discardableResult func getDictionarySettings(requestOptions: RequestOptions? = nil) throws -> String {
    let command = Command.Template()
    return try execute(command)
  }
  
}
