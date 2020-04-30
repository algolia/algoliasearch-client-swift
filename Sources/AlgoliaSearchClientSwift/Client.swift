//
//  Client.swift
//  
//
//  Created by Vladislav Fitc on 17.02.2020.
//

import Foundation

public struct Client: Credentials {

  let transport: Transport
  let operationLauncher: OperationLauncher
  let configuration: Configuration

  public var applicationID: ApplicationID {
    return transport.applicationID
  }

  public var apiKey: APIKey {
    return transport.apiKey
  }

  public internal(set) static var userAgents: Set<UserAgent> = [.operatingSystem, .library]

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
    self.init(transport: httpTransport, operationLauncher: operationLauncher, configuration: configuration)
  }

  init(transport: Transport, operationLauncher: OperationLauncher, configuration: Configuration) {
    self.transport = transport
    self.operationLauncher = operationLauncher
    self.configuration = configuration
  }

  public func index(withName indexName: IndexName) -> Index {
    return Index(name: indexName, transport: transport, operationLauncher: operationLauncher, configuration: configuration)
  }

  public static func append(userAgent: UserAgent) {
    userAgents.insert(userAgent)
  }

}

extension Client: Transport {

  func execute<Response: Codable, Output>(_ command: AlgoliaCommand, transform: @escaping (Response) -> Output, completion: @escaping (Result<Output, Error>) -> Void) -> Operation & TransportTask {
    return transport.execute(command, transform: transform, completion: completion)
  }

  func execute<Response: Codable, Output>(_ command: AlgoliaCommand, transform: @escaping (Response) -> Output) throws -> Output {
    return try transport.execute(command, transform: transform)
  }

}

extension Client {

  @discardableResult func launch<O: Operation>(_ operation: O) -> O {
    return operationLauncher.launch(operation)
  }

  func launch<O: OperationWithResult>(_ operation: O) throws -> O.ResultValue {
    return try operationLauncher.launchSync(operation)
  }

}
