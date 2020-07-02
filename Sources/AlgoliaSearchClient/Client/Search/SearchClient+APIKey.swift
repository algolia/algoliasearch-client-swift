//
//  SearchClient+APIKey.swift
//  
//
//  Created by Vladislav Fitc on 09/04/2020.
//

import Foundation

public extension SearchClient {

  // MARK: - Add API key

  /**
   Add a new APIKey.
   
   - Parameter parameters: permissions/restrictions specified by APIKeyParams
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func addAPIKey(with parameters: APIKeyParameters,
                                    requestOptions: RequestOptions? = nil,
                                    completion: @escaping ResultCallback<APIKeyCreation>) -> Operation {
    let command = Command.APIKey.Add(parameters: parameters, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Add a new APIKey.

   - Parameter parameters: permissions/restrictions specified by APIKeyParams
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: APIKeyCreation  object
   */
  @discardableResult func addAPIKey(with parameters: APIKeyParameters,
                                    requestOptions: RequestOptions? = nil) throws -> APIKeyCreation {
    let command = Command.APIKey.Add(parameters: parameters, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Update API key

  /**
   Update the permissions of an existing APIKey.
    
   - Parameter apiKey: APIKey to update
   - Parameter parameters: permissions/restrictions specified by APIKeyParameters
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func updateAPIKey(_ apiKey: APIKey,
                                       with parameters: APIKeyParameters,
                                       requestOptions: RequestOptions? = nil,
                                       completion: @escaping ResultCallback<APIKeyRevision>) -> Operation {
    let command = Command.APIKey.Update(apiKey: apiKey, parameters: parameters, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Update the permissions of an existing APIKey.
    
   - Parameter apiKey: APIKey to update
   - Parameter parameters: permissions/restrictions specified by APIKeyParameters
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: APIKeyRevision  object
   */
  @discardableResult func updateAPIKey(_ apiKey: APIKey,
                                       with parameters: APIKeyParameters,
                                       requestOptions: RequestOptions? = nil) throws -> APIKeyRevision {
    let command = Command.APIKey.Update(apiKey: apiKey, parameters: parameters, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Delete API key

  /**
   Delete an existing APIKey.
   
   - Parameter apiKey: APIKey to delete
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func deleteAPIKey(_ apiKey: APIKey,
                                       requestOptions: RequestOptions? = nil,
                                       completion: @escaping ResultCallback<APIKeyDeletion>) -> Operation {
    let command = Command.APIKey.Delete(apiKey: apiKey, requestOptions: requestOptions)
    let transform = APIKeyDeletion.transform(apiKey)
    return execute(command, transform: transform, completion: completion)
  }

  /**
   Delete an existing APIKey.
   
   - Parameter apiKey: APIKey to delete
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: APIKeyDeletion  object
   */
  @discardableResult func deleteAPIKey(_ apiKey: APIKey,
                                       requestOptions: RequestOptions? = nil) throws -> APIKeyDeletion {
    let command = Command.APIKey.Delete(apiKey: apiKey, requestOptions: requestOptions)
    let transform = APIKeyDeletion.transform(apiKey)
    return try execute(command, transform: transform)
  }

  // MARK: - Restore API key

  /**
   
   - Parameter apiKey: APIKey to restore
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func restoreAPIKey(_ apiKey: APIKey,
                                        requestOptions: RequestOptions? = nil,
                                        completion: @escaping ResultCallback<APIKeyCreation>) -> Operation {
    let command = Command.APIKey.Restore(apiKey: apiKey, requestOptions: requestOptions)
    let transform = APIKeyCreation.transform(apiKey)
    return execute(command, transform: transform, completion: completion)
  }

  /**
   
   - Parameter apiKey: APIKey to restore
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: APIKeyDeletion  object
   */
  @discardableResult func restoreAPIKey(_ apiKey: APIKey,
                                        requestOptions: RequestOptions? = nil) throws -> APIKeyCreation {
    let command = Command.APIKey.Restore(apiKey: apiKey, requestOptions: requestOptions)
    let transform = APIKeyCreation.transform(apiKey)
    return try execute(command, transform: transform)
  }

  // MARK: - Get API keys list

  /**
   Get the full list of API Keys
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func listAPIKeys(requestOptions: RequestOptions? = nil,
                                      completion: @escaping ResultCallback<ListAPIKeysResponse>) -> Operation {
    let command = Command.APIKey.List(requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Get the full list of API Keys
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: ListAPIKeyResponse  object
   */
  @discardableResult func listAPIKeys(requestOptions: RequestOptions? = nil) throws -> ListAPIKeysResponse {
    let command = Command.APIKey.List(requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Get API key

  /**
   Get the permissions of an APIKey. When initializing the client using the Admin APIKey, you can request information on any of your application’s API keys.

   - Parameter apiKey: APIKey to retrieve permissions for
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func getAPIKey(_ apiKey: APIKey,
                                    requestOptions: RequestOptions? = nil,
                                    completion: @escaping ResultCallback<APIKeyResponse>) -> Operation {
    let command = Command.APIKey.Get(apiKey: apiKey, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Get the permissions of an APIKey. When initializing the client using the Admin APIKey, you can request information on any of your application’s API keys.
   
   - Parameter apiKey: APIKey to retrieve permissions for
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: APIKeyResponse  object
   */
  @discardableResult func getAPIKey(_ apiKey: APIKey,
                                    requestOptions: RequestOptions? = nil) throws -> APIKeyResponse {
    let command = Command.APIKey.Get(apiKey: apiKey, requestOptions: requestOptions)
    return try execute(command)
  }

}
