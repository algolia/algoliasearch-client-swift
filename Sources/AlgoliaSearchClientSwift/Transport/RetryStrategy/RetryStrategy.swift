//
//  RetryStrategy.swift
//  
//
//  Created by Vladislav Fitc on 20/02/2020.
//

import Foundation

extension Optional where Wrapped: Equatable {
  
  func isNilOrEqual(to value: Wrapped) -> Bool {
    return self == nil || self == value
  }
  
}

protocol RetryStrategy {
  
  mutating func host(for callType: CallType) -> RetryableHost?
  mutating func notify<T>(host: RetryableHost, result: Result<T, Swift.Error>) throws -> RetryOutcome

}

/** Algolia's retry strategy in case of server error, timeouts... */
public struct AlgoliaRetryStrategy: RetryStrategy {
  
  private var hosts: [RetryableHost]
  
  init(hosts: [RetryableHost]) {
    self.hosts = hosts
  }
  
  init(configuration: Configuration) {
    self.init(hosts: configuration.hosts)
  }
  
  mutating func host(for callType: CallType) -> RetryableHost? {
    
    hosts.resetExpired()
    
    let hostsForCallType = hosts.filter { $0.callType.isNilOrEqual(to: callType) }
    
    guard !hostsForCallType.isEmpty else {
      return .none
    }
        
    guard let firstUpHost = hostsForCallType.first(where: { $0.isUp }) else {
      hosts.resetAll(for: callType)
      return host(for: callType)
    }
    
    return firstUpHost
    
  }
  
  mutating func notify<T>(host: RetryableHost, result: Result<T, Swift.Error>) throws -> RetryOutcome {
        
    guard let hostIndex = hosts.firstIndex(where: { $0.url == host.url }) else {
      throw Error.unexpectedHost
    }
    
    switch result {
    case .success:
      hosts[hostIndex].reset()
      return .success
      
    case .failure(let error) where error.isTimeout:
      hosts[hostIndex].hasTimedOut()
      return .retry
      
    case .failure(let error) where error.isRetryable:
      hosts[hostIndex].hasFailed()
      return .retry
      
    case .failure(let error):
      throw error
    }
        
  }
  
  enum Error: Swift.Error {
    case unexpectedHost
    
    var localizedDescription: String {
      return "Attempt to notify a host which is not in the strategy list"
    }
  }
    
}

extension Error {

  var isRetryable: Bool {
    switch self {
    case is URLError:
      return true
      
    case let httpError as HTTPError where !httpError.statusCode.belongs(to: .success, .clientError):
      return true
      
    default:
      return false
    }
  }
  
  var isTimeout: Bool {
    switch self {
    case let urlError as URLError:
      return urlError.code == .timedOut
      
    case let httpError as HTTPError:
      return httpError.statusCode == .requestTimeout
      
    default:
      return false
    }
  }

}
