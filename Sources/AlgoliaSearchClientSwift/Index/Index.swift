//
//  File.swift
//  
//
//  Created by Vladislav Fitc on 19/02/2020.
//

import Foundation

public struct Index {
  
  public let name: IndexName
  let transport: Transport
  let queue: OperationQueue
  
  public init(name: IndexName) {
    let transport = HttpTransport(configuration: DefaultConfiguration.default)
    let queue = OperationQueue()
    queue.qualityOfService = .userInitiated
    self.init(name: name, transport: transport, queue: queue)
  }
  
  init(name: IndexName, transport: Transport, queue: OperationQueue) {
    self.name = name
    self.transport = transport
    self.queue = queue
  }
  
}

