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
    
    let httpTransport = HttpTransport(requester: session, configuration: configuration, retryStrategy: retryStrategy, credentials: configuration, operationLauncher: operationLauncher)
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
  
  //MARK: - Custom request
  
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
  
  //MARK: - Get logs
  
  /**
   Get the logs of the latest search and indexing operations.
   You can retrieve the logs of your last 1,000 API calls. It is designed for immediate, real-time debugging.
   All logs older than 7 days will be removed and won’t be accessible anymore from the API.
   This API is counted in your operation quota but is not logged.

   - Parameter page: Specify the first entry to retrieve (0-based, 0 is the most recent log entry).
   - Parameter hitsPerPage: Specify the maximum number of entries to retrieve starting at the page. Maximum allowed value: 1,000.
   - Parameter logType: Type of logs to retrieve.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func getLogs(page: Int? = nil, hitsPerPage: Int? = nil, type: LogType = .all, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<LogsResponse>) -> Operation {
    let command = Command.Advanced.GetLogs(indexName: nil, page: page, hitsPerPage: hitsPerPage, logType: type, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }
  
  /**
   Get the logs of the latest search and indexing operations.
   You can retrieve the logs of your last 1,000 API calls. It is designed for immediate, real-time debugging.
   All logs older than 7 days will be removed and won’t be accessible anymore from the API.
   This API is counted in your operation quota but is not logged.
   
   - Parameter page: Specify the first entry to retrieve (0-based, 0 is the most recent log entry).
   - Parameter hitsPerPage: Specify the maximum number of entries to retrieve starting at the page. Maximum allowed value: 1,000.
   - Parameter logType: Type of logs to retrieve.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: LogsResponse  object
   */
  @discardableResult func getLogs(page: Int? = nil, hitsPerPage: Int? = nil, type: LogType = .all, requestOptions: RequestOptions? = nil) throws -> LogsResponse {
    let command = Command.Advanced.GetLogs(indexName: nil, page: page, hitsPerPage: hitsPerPage, logType: type, requestOptions: requestOptions)
    return try execute(command)
  }
  
}
