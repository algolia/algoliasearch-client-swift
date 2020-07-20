//
//  AlgoliaRetryStrategy.swift
//  
//
//  Created by Vladislav Fitc on 17/03/2020.
//

import Foundation

/** Algolia's retry strategy in case of server error, timeouts... */

class AlgoliaRetryStrategy: RetryStrategy {

  private var hosts: [RetryableHost]
  let hostsExpirationDelay: TimeInterval

  /// Concurrent synchronization queue
  private let queue = DispatchQueue(label: "AlgoliaRetryStrategySync.queue")

  init(hosts: [RetryableHost], hostsExpirationDelay: TimeInterval = .minutes(5)) {
    self.hosts = hosts
    self.hostsExpirationDelay = hostsExpirationDelay
  }

  convenience init(configuration: Configuration) {
    self.init(hosts: configuration.hosts)
  }

  func host(for callType: CallType) -> RetryableHost? {
    return queue.sync {
      hosts.resetExpired(expirationDelay: hostsExpirationDelay)

      func firstUpHostForCallType() -> RetryableHost? {
        return hosts.first { $0.supports(callType) && $0.isUp }
      }

      guard let host = firstUpHostForCallType() else {
        hosts.resetAll(for: callType)
        return firstUpHostForCallType()
      }

      return host
    }

  }

  func notify<T>(host: RetryableHost, result: Result<T, Swift.Error>) -> RetryOutcome<T> {
    return queue.sync {

      guard let hostIndex = hosts.firstIndex(where: { $0.url == host.url }) else {
        return .failure(Error.unexpectedHost)
      }

      switch result {
      case .success(let value):
        hosts[hostIndex].reset()
        return .success(value)

      case .failure(let error) where error.isTimeout:
        hosts[hostIndex].hasTimedOut()
        return .retry

      case .failure(let error) where error.isRetryable:
        hosts[hostIndex].hasFailed()
        return .retry

      case .failure(let error):
        return .failure(error)
      }
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
    return hosts.map(\.debugDescription).joined(separator: "\n")
  }

}
