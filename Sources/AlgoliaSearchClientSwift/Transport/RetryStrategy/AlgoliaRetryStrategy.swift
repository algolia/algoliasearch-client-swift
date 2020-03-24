//
//  AlgoliaRetryStrategy.swift
//  
//
//  Created by Vladislav Fitc on 17/03/2020.
//

import Foundation

/** Algolia's retry strategy in case of server error, timeouts... */

struct AlgoliaRetryStrategy: RetryStrategy {

  private var hosts: [RetryableHost]
  let hostsExpirationDelay: TimeInterval

  init(hosts: [RetryableHost], hostsExpirationDelay: TimeInterval = .minutes(5)) {
    self.hosts = hosts
    self.hostsExpirationDelay = hostsExpirationDelay
  }

  init(configuration: Configuration) {
    self.init(hosts: configuration.hosts)
  }

  mutating func host(for callType: CallType) -> RetryableHost? {

    hosts.resetExpired(expirationDelay: hostsExpirationDelay)

    let hostsForCallType = hosts.filter { $0.supports(callType) }

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

extension AlgoliaRetryStrategy: CustomDebugStringConvertible {

  public var debugDescription: String {
    return hosts.map { $0.debugDescription }.joined(separator: "\n")
  }

}
