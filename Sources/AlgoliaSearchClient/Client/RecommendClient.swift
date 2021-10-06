//
//  RecommendClient.swift
//  
//
//  Created by Vladislav Fitc on 31/08/2021.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Client to perform recommend operations.
public struct RecommendClient: Credentials {

  let transport: Transport
  let operationLauncher: OperationLauncher
  let configuration: Configuration

  public var applicationID: ApplicationID {
    return transport.applicationID
  }

  public var apiKey: APIKey {
    return transport.apiKey
  }

  public init(appID: ApplicationID, apiKey: APIKey) {

    let configuration = SearchConfiguration(applicationID: appID, apiKey: apiKey)

    let sessionConfiguration: URLSessionConfiguration = .default
    sessionConfiguration.httpAdditionalHeaders = configuration.defaultHeaders
    let session = URLSession(configuration: sessionConfiguration)

    self.init(configuration: configuration, requester: session)

  }

  public init(configuration: SearchConfiguration,
              requester: HTTPRequester = URLSession(configuration: .default)) {

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

  /// Initialize an Index configured with SearchConfiguration.
  public func index(withName indexName: IndexName) -> Index {
    return Index(name: indexName, transport: transport, operationLauncher: operationLauncher, configuration: configuration)
  }

}

extension RecommendClient: TransportContainer {}

extension RecommendClient {

  @discardableResult func launch<O: Operation>(_ operation: O) -> O {
    return operationLauncher.launch(operation)
  }

  func launch<O: OperationWithResult>(_ operation: O) throws -> O.ResultValue {
    return try operationLauncher.launchSync(operation)
  }

}

public extension RecommendClient {

  /**
   Returns recommendations.
   
   - parameter options: Recommend request options
   - parameter requestOptions: Configure request locally with RequestOptions
   - parameter completion: Result completion
   - returns: Launched asynchronous operation
   */
  @discardableResult func getRecommendations(options: [RecommendationsOptions],
                                             requestOptions: RequestOptions? = nil,
                                             completion: @escaping ResultCallback<SearchesResponse>) -> Operation {
    let command = Command.Recommend.GetRecommendations(options: options, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Returns recommendations.
   
   - parameter options: Recommend request options
   - parameter requestOptions: Configure request locally with RequestOptions
   - returns: SearchesResponse object
   */
  @discardableResult func getRecommendations(options: [RecommendationsOptions],
                                             requestOptions: RequestOptions? = nil) throws -> SearchesResponse {
    let command = Command.Recommend.GetRecommendations(options: options, requestOptions: requestOptions)
    return try execute(command)
  }

  /**
   Returns [Related Products](https://algolia.com/doc/guides/algolia-ai/recommend/#related-products).
   
   - parameter options: Recommend request options
   - parameter requestOptions: Configure request locally with RequestOptions
   - parameter completion: Result completion
   - returns: Launched asynchronous operation
   */
  @discardableResult func getRelatedProducts(options: [RelatedProductsOptions],
                                             requestOptions: RequestOptions? = nil,
                                             completion: @escaping ResultCallback<SearchesResponse>) -> Operation {
    return getRecommendations(options: options.map(\.recommendationsOptions),
                              requestOptions: requestOptions,
                              completion: completion)
  }

  /**
   Returns [Related Products](https://algolia.com/doc/guides/algolia-ai/recommend/#related-products).
   
   - parameter options: Recommend request options
   - parameter requestOptions: Configure request locally with RequestOptions
   - returns: SearchesResponse object
   */
  @discardableResult func getRelatedProducts(options: [RelatedProductsOptions],
                                             requestOptions: RequestOptions? = nil) throws -> SearchesResponse {
    return try getRecommendations(options: options.map(\.recommendationsOptions),
                                  requestOptions: requestOptions)
  }

  /**
   Returns [Frequently Bought Together](https://algolia.com/doc/guides/algolia-ai/recommend/#frequently-bought-together) products.
   
   - parameter options: Recommend request options
   - parameter requestOptions: Configure request locally with RequestOptions
   - parameter completion: Result completion
   - returns: Launched asynchronous operation
   */
  @discardableResult func getFrequentlyBoughtTogether(options: [FrequentlyBoughtTogetherOptions],
                                                      requestOptions: RequestOptions? = nil,
                                                      completion: @escaping ResultCallback<SearchesResponse>) -> Operation {
    return getRecommendations(options: options.map(\.recommendationsOptions),
                              requestOptions: requestOptions,
                              completion: completion)
  }

  /**
   Returns [Frequently Bought Together](https://algolia.com/doc/guides/algolia-ai/recommend/#frequently-bought-together) products.
   
   - parameter options: Recommend request options
   - parameter requestOptions: Configure request locally with RequestOptions
   - returns: SearchesResponse object
   */
  @discardableResult func getFrequentlyBoughtTogether(options: [FrequentlyBoughtTogetherOptions],
                                                      requestOptions: RequestOptions? = nil) throws -> SearchesResponse {
    return try getRecommendations(options: options.map(\.recommendationsOptions),
                                  requestOptions: requestOptions)
  }

}
