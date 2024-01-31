//
//  AlgoliaRetryStrategy.swift
//
//
//  Created by Algolia on 17/03/2020.
//

import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

/// Algolia's retry strategy in case of server error, timeouts...

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
                    retryStrategy.hosts
                        .sorted { $0.lastUpdated.compare($1.lastUpdated) == .orderedAscending }
                        .first { $0.supports(callType) && $0.isUp }
                }
            }
        }
    }

    func notify(host: RetryableHost, error: Error? = nil) {
        queue.sync {
            guard let hostIndex = hosts.firstIndex(where: { $0.url == host.url }) else {
                assertionFailure("Attempt to notify a host which is not in the strategy list")
                return
            }

            guard let error = error else {
                hosts[hostIndex].reset()
                return
            }

            if isTimeout(error) {
                hosts[hostIndex].hasTimedOut()
                return
            }

            if isRetryable(error) {
                hosts[hostIndex].hasFailed()
                return
            }
        }
    }

    func isRetryable(_ error: Error) -> Bool {
        switch error {
        case let .requestError(error) as AlgoliaError where error is URLError:
            return true

        case let .httpError(httpError) as AlgoliaError
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
        case let .requestError(error as URLError) as AlgoliaError where error.code == .timedOut:
            return true

        case let .httpError(error) as AlgoliaError where error.statusCode == .requestTimeout:
            return true

        default:
            return false
        }
    }

    func canRetry<E: Error>(inCaseOf error: E) -> Bool {
        isTimeout(error) || isRetryable(error)
    }
}

extension AlgoliaRetryStrategy: CustomDebugStringConvertible {
    public var debugDescription: String {
        hosts.map(\.debugDescription).joined(separator: "\n")
    }
}
