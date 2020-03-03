//
//  HostIterator.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation

protocol RetryStrategyContainer: class {
  var retryStrategy: RetryStrategy { get set }
}

class HostIterator: IteratorProtocol {
  
  let container: RetryStrategyContainer
  let callType: CallType
  
  init(container: RetryStrategyContainer, callType: CallType) {
    self.container = container
    self.callType = callType
  }
  
  func next() -> RetryableHost? {
    return container.retryStrategy.host(for: callType)
  }
  
}
