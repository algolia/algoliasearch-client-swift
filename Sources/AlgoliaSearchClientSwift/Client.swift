//
//  File.swift
//  
//
//  Created by Vladislav Fitc on 17.02.2020.
//

import Foundation

public struct Client {
  
  let transport: Transport
  let queue: OperationQueue
  
  public init(appID: ApplicationID, apiKey: APIKey) {
    let credentials = AlgoliaCredentials(applicationID: appID, apiKey: apiKey)
    let retryStrategy = AlgoliaRetryStrategy(hosts: .init(forApplicationID: appID))
    let httpTransport = HttpTransport(configuration: DefaultConfiguration.default,
                                      credentials: credentials,
                                      retryStrategy: retryStrategy)
    self.init(transport: httpTransport)
  }
  
  init(transport: Transport) {
    self.transport = transport
    self.queue = OperationQueue()
    queue.qualityOfService = .userInitiated
  }
  
  func index(withName indexName: IndexName) -> Index {
    return Index(name: indexName, transport: transport, queue: queue)
  }
  
}
