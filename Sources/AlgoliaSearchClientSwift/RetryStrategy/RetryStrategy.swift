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
    
    func isRetryable(response: HTTPURLResponse, error: Error?) -> Bool {
        guard let statusCode = HTTPStatusCode(rawValue: response.statusCode) else {
            return false
        }
        return error != nil || !statusCode.isSuccess || !statusCode.isClientError

    }
  
    func decide(host: RetryableHost, response: HTTPURLResponse, error: Error) -> RetryOutcome {
    
        guard let statusCode = HTTPStatusCode(rawValue: response.statusCode) else {
            return .failure
        }
        
        var mutableHost = host
        let isTimedOut = (error as? URLError)?.code == .timedOut
        let isRetryable = self.isRetryable(response: response, error: error)
        
        switch (isTimedOut, statusCode.isSuccess, isRetryable) {
        case (false, true, _):
            mutableHost.reset()
            return .success
        case (false, _, isRetryable):
            mutableHost.hasFailed()
            return .retry
        case (true, _, _):
            mutableHost.hasTimedOut()
            return .retry
        default:
            return .failure
        }
                
    }

  
}
