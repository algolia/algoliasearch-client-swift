//
//  RetryStrategy.swift
//  
//
//  Created by Vladislav Fitc on 20/02/2020.
//

import Foundation

/** Algolia's retry strategy in case of server error, timeouts... */
struct RetryStrategy {
  
  private var hosts: [RetryableHost]
  
  init(configuration: Configuration) {
    self.hosts = configuration.hosts
  }
  
  mutating func callableHosts(for callType: CallType) -> [RetryableHost] {
    
    hosts.resetExpired()
    
    let hostsForCallType = hosts.filterCallType(callType: callType)
    
    guard !hostsForCallType.isEmpty else {
      return []
    }
    
    let upHostsForCallType = hostsForCallType.filter { $0.isUp }
    
    guard upHostsForCallType.isEmpty else {
      hosts.resetAll(for: callType)
      return callableHosts(for: callType)
    }
    
    return upHostsForCallType
    
  }
  
  func decide(host: RetryableHost, response: HTTPURLResponse) -> RetryOutcome {
    

    
    return .failure
    
  }

  
}
