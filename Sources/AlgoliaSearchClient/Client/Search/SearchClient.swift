//
//  SearchClient.swift
//
//
//  Created by Vladislav Fitc on 17.02.2020.
//

import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

typealias Client = SearchClient

/// Client to perform operations on indices.
public struct SearchClient: Credentials {
  let transport: Transport
  let operationLauncher: OperationLauncher
  let configuration: Configuration

  public var applicationID: ApplicationID {
    transport.applicationID
  }

  public var apiKey: APIKey {
    transport.apiKey
  }

  public init(appID: ApplicationID, apiKey: APIKey) {
    let configuration = SearchConfiguration(applicationID: appID, apiKey: apiKey)

    let sessionConfiguration: URLSessionConfiguration = .default
    sessionConfiguration.httpAdditionalHeaders = configuration.defaultHeaders
    let session = URLSession(configuration: sessionConfiguration)

    self.init(configuration: configuration, requester: session)
  }

  public init(
    configuration: SearchConfiguration,
    requester: HTTPRequester = URLSession(configuration: .default)
  ) {
    let queue = OperationQueue()
    queue.qualityOfService = .userInitiated
    let operationLauncher = OperationLauncher(queue: queue)

    let retryStrategy = AlgoliaRetryStrategy(configuration: configuration)

    let httpTransport = HTTPTransport(
      requester: requester,
      configuration: configuration,
      retryStrategy: retryStrategy,
      credentials: configuration,
      operationLauncher: operationLauncher)
    self.init(
      transport: httpTransport, operationLauncher: operationLauncher, configuration: configuration)
  }

  init(
    transport: Transport,
    operationLauncher: OperationLauncher,
    configuration: Configuration
  ) {
    self.transport = transport
    self.operationLauncher = operationLauncher
    self.configuration = configuration
  }

  /// Initialize an Index configured with SearchConfiguration.
  public func index(withName indexName: IndexName) -> Index {
    Index(
      name: indexName, transport: transport, operationLauncher: operationLauncher,
      configuration: configuration)
  }
}

extension SearchClient: TransportContainer {}

extension SearchClient {
  func execute<Output: Codable & AppTask>(
    _ command: some AlgoliaCommand,
    completion: @escaping ResultAppTaskCallback<Output>
  ) -> Operation & TransportTask {
    transport.execute(command, transform: WaitableWrapper.wrap(with: self), completion: completion)
  }

  func execute<Output: Codable & AppTask>(_ command: some AlgoliaCommand) throws -> WaitableWrapper<
    Output
  > {
    try transport.execute(command, transform: WaitableWrapper.wrap(with: self))
  }
}

extension SearchClient {
  @discardableResult func launch<O: Operation>(_ operation: O) -> O {
    operationLauncher.launch(operation)
  }

  func launch<O: OperationWithResult>(_ operation: O) throws -> O.ResultValue {
    try operationLauncher.launchSync(operation)
  }
}
