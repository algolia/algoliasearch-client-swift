//
//  Client+CustomRequest.swift
//  
//
//  Created by Vladislav Fitc on 18/04/2020.
//

import Foundation

extension Transport {

  // MARK: - Custom request

  /**
    Custom request
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func customRequest<T: Codable>(callType: CallType, request: URLRequest, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<T>) -> Operation {
    let command = Command.Custom(callType: callType, urlRequest: request, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
    Custom request
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Specified generic  object
   */
  @discardableResult func customRequest<T: Codable>(callType: CallType, request: URLRequest, requestOptions: RequestOptions? = nil) throws -> T {
    let command = Command.Custom(callType: callType, urlRequest: request, requestOptions: requestOptions)
    return try execute(command)
  }

}
