//
//  InsightsClient.swift
//  
//
//  Created by Vladislav Fitc on 23/04/2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct InsightsClient: Credentials {

  let transport: Transport
  let operationLauncher: OperationLauncher
  let configuration: Configuration

  public var applicationID: ApplicationID {
    return transport.applicationID
  }

  public var apiKey: APIKey {
    return transport.apiKey
  }

  public init(appID: ApplicationID, apiKey: APIKey, region: Region? = nil) {

    let configuration = InsightsConfiguration(applicationID: appID, apiKey: apiKey, region: region)
    let sessionConfiguration: URLSessionConfiguration = .default
    sessionConfiguration.httpAdditionalHeaders = configuration.defaultHeaders

    let session = URLSession(configuration: sessionConfiguration)

    self.init(configuration: configuration, requester: session)

  }

  public init(configuration: InsightsConfiguration, requester: HTTPRequester) {

    let queue = OperationQueue()
    queue.qualityOfService = .userInitiated
    let operationLauncher = OperationLauncher(queue: queue)

    let retryStrategy = AlgoliaRetryStrategy(configuration: configuration)

    let httpTransport = HTTPTransport(requester: requester,
                                      configuration: configuration,
                                      retryStrategy: retryStrategy,
                                      credentials: configuration,
                                      operationLauncher: operationLauncher)

    self.init(transport: httpTransport, operationLauncher: operationLauncher, configuration: configuration)

  }

  init(transport: Transport,
       operationLauncher: OperationLauncher,
       configuration: Configuration) {
    self.transport = transport
    self.operationLauncher = operationLauncher
    self.configuration = configuration
  }

}

extension InsightsClient: TransportContainer {}

public extension InsightsClient {

  // MARK: - Send event

  /**
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func sendEvent(_ event: InsightsEvent, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<Empty>) -> Operation {
    return sendEvents([event], requestOptions: requestOptions, completion: completion)
  }

  /**
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: JSON  object
   */
  @discardableResult func sendEvent(_ event: InsightsEvent, requestOptions: RequestOptions? = nil) throws -> Empty {
    return try sendEvents([event], requestOptions: requestOptions)
  }

  // MARK: - Send events

  /**
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func sendEvents(_ events: [InsightsEvent], requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<Empty>) -> Operation {
    let command = Command.Insights.SendEvents(events: events, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: JSON  object
   */
  @discardableResult func sendEvents(_ events: [InsightsEvent], requestOptions: RequestOptions? = nil) throws -> Empty {
    var updatedRequestOptions = requestOptions ?? .init()
    updatedRequestOptions.setHeader("application/json", forKey: .contentType)
    let requestOptions = updatedRequestOptions
    let command = Command.Insights.SendEvents(events: events, requestOptions: requestOptions)
    return try execute(command)
  }

}
