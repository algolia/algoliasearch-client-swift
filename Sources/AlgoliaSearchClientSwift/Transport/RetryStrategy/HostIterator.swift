//
//  HostIterator.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation

class HostIterator: IteratorProtocol {

  var retryStrategy: RetryStrategy
  let callType: CallType

  init(retryStrategy: RetryStrategy, callType: CallType) {
    self.retryStrategy = retryStrategy
    self.callType = callType
  }

  func next() -> RetryableHost? {
    return retryStrategy.host(for: callType)
  }

}
