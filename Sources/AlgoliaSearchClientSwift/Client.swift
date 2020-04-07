//
//  Client.swift
//  
//
//  Created by Vladislav Fitc on 17.02.2020.
//

import Foundation

public struct Client {

  let transport: Transport
  let operationLauncher: OperationLauncher

  public init(appID: ApplicationID, apiKey: APIKey) {
    let configuration = SearchConfigration(applicationID: appID, apiKey: apiKey)
    let sessionConfiguration: URLSessionConfiguration = .default
    sessionConfiguration.httpAdditionalHeaders = configuration.defaultHeaders

    let session = URLSession(configuration: sessionConfiguration)
    let retryStrategy = AlgoliaRetryStrategy(configuration: configuration)

    let queue = OperationQueue()
    queue.qualityOfService = .userInitiated
    let operationLauncher = OperationLauncher(queue: queue)
    
    let httpTransport = HttpTransport(requester: session, configuration: configuration, operationLauncher: operationLauncher, retryStrategy: retryStrategy, credentials: configuration)
    self.init(transport: httpTransport, operationLauncher: operationLauncher)
  }

  init(transport: Transport, operationLauncher: OperationLauncher) {
    self.transport = transport
    self.operationLauncher = operationLauncher
  }

  public func index(withName indexName: IndexName) -> Index {
    return Index(name: indexName, transport: transport, operationLauncher: operationLauncher)
  }

}

extension Client {
  
  func execute<T: Codable>(_ command: AlgoliaCommand, completion: @escaping ResultCallback<T>) -> Operation & TransportTask {
    return transport.execute(command, completion: completion)
  }
  
  func execute<T: Codable>(_ command: AlgoliaCommand) throws -> T {
    return try transport.execute(command)
  }
  
  @discardableResult func launch<O: Operation>(_ operation: O) -> O {
    return operationLauncher.launch(operation)
  }
  
  func launch<O: OperationWithResult>(_ operation: O) throws -> O.ResultValue {
    return try operationLauncher.launchSync(operation)
  }
  
}

public extension Client {
  
  /**
    Custom request
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func customRequest<T: Codable>(request: URLRequest, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<T>) -> Operation {
    let command = Command.Custom(callType: .read, urlRequest: request, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }
  
  /**
    Custom request
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Specified generic  object
   */
  
  @discardableResult func customRequest<T: Codable>(request: URLRequest, requestOptions: RequestOptions? = nil) throws -> T {
    let command = Command.Custom(callType: .read, urlRequest: request, requestOptions: requestOptions)
    return try execute(command)
  }
  
}
