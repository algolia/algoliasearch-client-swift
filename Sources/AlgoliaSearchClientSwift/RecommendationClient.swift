//
//  RecommendationClient.swift
//  
//
//  Created by Vladislav Fitc on 27/05/2020.
//

import Foundation

public struct RecommendationClient: Credentials {

  let transport: Transport
  let operationLauncher: OperationLauncher

  public var applicationID: ApplicationID {
    return transport.applicationID
  }

  public var apiKey: APIKey {
    return transport.apiKey
  }

  public init(appID: ApplicationID, apiKey: APIKey, region: Region? = nil) {

    let configuration = RecommendationConfiguration(applicationID: appID, apiKey: apiKey, region: region)
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

}

public extension RecommendationClient {
  
  //MARK: - Set personalization strategy
  
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
    return transport.execute(command, completion: completion)
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
    return try transport.execute(command)
  }
  
  //MARK: - Get personalization strategy
  
  /**
   Returns the personalization strategy of the application
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func getPersonalizationStrategy(requestOptions: RequestOptions? = nil,
                                                     completion: @escaping ResultCallback<PersonalizationStrategy>) -> Operation {
    let command = Command.Personalization.Get(requestOptions: requestOptions)
    return transport.execute(command, completion: completion)
  }
  
  /**
   Returns the personalization strategy of the application

   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: PersonalizationStrategy  object
   */
  @discardableResult func getPersonalizationStrategy(requestOptions: RequestOptions? = nil) throws -> PersonalizationStrategy {
    let command = Command.Personalization.Get(requestOptions: requestOptions)
    return try transport.execute(command)
  }
  
}
