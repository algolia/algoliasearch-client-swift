//
//  Client.swift
//  
//
//  Created by Vladislav Fitc on 17.02.2020.
//

import Foundation

public struct Client {
  
  let transport: Transport
  let queue: OperationQueue
  
  public init(appID: ApplicationID, apiKey: APIKey) {
    let configuration = SearchConfigration(applicationID: appID, apiKey: apiKey)
    let sessionConfiguration: URLSessionConfiguration = .default
    sessionConfiguration.httpAdditionalHeaders = configuration.defaultHeaders
    let session = URLSession(configuration: sessionConfiguration)
    let retryStrategy = AlgoliaRetryStrategy(configuration: configuration)
    let httpTransport = HttpTransport(requester: session,
                                      configuration: configuration,
                                      credentials: configuration,
                                      retryStrategy: retryStrategy)
    self.init(transport: httpTransport)
  }
  
  init(transport: Transport) {
    self.transport = transport
    self.queue = OperationQueue()
    queue.qualityOfService = .userInitiated
  }
  
  public func index(withName indexName: IndexName) -> Index {
    return Index(name: indexName, transport: transport, queue: queue)
  }
  
}
