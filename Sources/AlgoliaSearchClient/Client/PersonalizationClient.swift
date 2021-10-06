//
//  PersonalizationClient.swift
//  
//
//  Created by Vladislav Fitc on 05/07/2021.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct PersonalizationClient: Credentials {

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

    let configuration = PersonalizationConfiguration(applicationID: appID, apiKey: apiKey, region: region)
    let sessionConfiguration: URLSessionConfiguration = .default
    sessionConfiguration.httpAdditionalHeaders = configuration.defaultHeaders

    let session = URLSession(configuration: sessionConfiguration)

    self.init(configuration: configuration, requester: session)

  }

  public init(configuration: PersonalizationConfiguration, requester: HTTPRequester) {

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

extension PersonalizationClient: TransportContainer {}

public extension PersonalizationClient {

  // MARK: - Set personalization strategy

  /**
   Configures the personalization strategy
   
   - Parameter personalizationStrategy: PersonalizationStrategy to set
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func setPersonalizationStrategy(_ personalizationStrategy: PersonalizationStrategy,
                                                     requestOptions: RequestOptions? = nil,
                                                     completion: @escaping ResultCallback<SetStrategyResponse>) -> Operation {
    let command = Command.Personalization.Set(strategy: personalizationStrategy, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Configures the personalization strategy

   - Parameter personalizationStrategy: PersonalizationStrategy to set
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Revision  object
   */
  @discardableResult func setPersonalizationStrategy(_ personalizationStrategy: PersonalizationStrategy,
                                                     requestOptions: RequestOptions? = nil) throws -> SetStrategyResponse {
    let command = Command.Personalization.Set(strategy: personalizationStrategy, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Get personalization strategy

  /**
   Returns the personalization strategy of the application
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func getPersonalizationStrategy(requestOptions: RequestOptions? = nil,
                                                     completion: @escaping ResultCallback<PersonalizationStrategy>) -> Operation {
    let command = Command.Personalization.Get(requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Returns the personalization strategy of the application

   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: PersonalizationStrategy  object
   */
  @discardableResult func getPersonalizationStrategy(requestOptions: RequestOptions? = nil) throws -> PersonalizationStrategy {
    let command = Command.Personalization.Get(requestOptions: requestOptions)
    return try execute(command)
  }

}

@available(*, deprecated, renamed: "PersonalizationClient")
public typealias RecommendationClient = PersonalizationClient
