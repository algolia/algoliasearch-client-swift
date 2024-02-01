//
//  AlgoliaRetryStrategy.swift
//
//
//  Created by Vladislav Fitc on 17/03/2020.
//

import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

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

  func retryableHosts(for callType: CallType) -> HostIterator {
    queue.sync {
      // Reset expired hosts
      hosts.resetExpired(expirationDelay: hostsExpirationDelay)

      // If all hosts of the required type are down, reset them all
      if !hosts.contains(where: { $0.supports(callType) && $0.isUp }) {
        hosts.resetAll(for: callType)
      }

      return HostIterator { [weak self] in
        guard let retryStrategy = self else { return nil }
        return retryStrategy.queue.sync {
          return retryStrategy.hosts.first { $0.supports(callType) && $0.isUp }
        }
      }
    }
  }

  func notify(host: RetryableHost, result: Result<some Any, Swift.Error>) {
    queue.sync {
      guard let hostIndex = hosts.firstIndex(where: { $0.url == host.url }) else {
        assertionFailure("Attempt to notify a host which is not in the strategy list")
        return
      }

      switch result {
      case .success:
        hosts[hostIndex].reset()

      case .failure(let error) where isTimeout(error):
        hosts[hostIndex].hasTimedOut()

      case .failure(let error) where isRetryable(error):
        hosts[hostIndex].hasFailed()

      case .failure:
        return
      }
    }
  }

  func isRetryable(_ error: Error) -> Bool {
    switch error {
    case .requestError(let error) as TransportError where error is URLError:
      return true

    case .httpError(let httpError) as TransportError
    where !httpError.statusCode.belongs(to: .success, .clientError):
      return true

    case .badHost as URLRequest.FormatError:
      return true

    default:
      return false
    }
  }

  func isTimeout(_ error: Error) -> Bool {
    switch error {
    case .requestError(let error as URLError) as TransportError where error.code == .timedOut:
      return true

    case .httpError(let error) as TransportError where error.statusCode == .requestTimeout:
      return true

    default:
      return false
    }
  }

  func canRetry(inCaseOf error: some Error) -> Bool {
    isTimeout(error) || isRetryable(error)
  }
}

extension AlgoliaRetryStrategy: CustomDebugStringConvertible {
  public var debugDescription: String {
    hosts.map(\.debugDescription).joined(separator: "\n")
  }
}
