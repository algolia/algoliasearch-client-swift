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

// MARK: - AlgoliaRetryStrategy

// Algolia's retry strategy in case of server error, timeouts...

class AlgoliaRetryStrategy: RetryStrategy {
    private var hosts: [RetryableHost]
    /// Concurrent synchronization queue
    private let queue = DispatchQueue(label: "AlgoliaRetryStrategySync.queue")

    let hostsExpirationDelay: TimeInterval

    init(hosts: [RetryableHost], hostsExpirationDelay: TimeInterval = .minutes(5)) {
        self.hosts = hosts
        self.hostsExpirationDelay = hostsExpirationDelay
    }

    convenience init(configuration: BaseConfiguration) {
        self.init(hosts: configuration.hosts)
    }

    func retryableHosts(for callType: CallType) -> HostIterator {
        self.queue.sync {
            // Reset expired hosts
            self.hosts.resetExpired(expirationDelay: self.hostsExpirationDelay)

            // If all hosts of the required type are down, reset them all
            if !self.hosts.contains(where: { $0.supports(callType) && $0.isUp }) {
                self.hosts.resetAll(for: callType)
            }

            var hostIterator = self.hosts
                .filter { $0.supports(callType) && $0.isUp }
                .makeIterator()

            return HostIterator { [weak self] in
                guard let retryStrategy = self else { return nil }
                return retryStrategy.queue.sync {
                    hostIterator.next()
                }
            }
        }
    }

    func notify(host: RetryableHost, error: Error? = nil) {
        self.queue.sync {
            guard let hostIndex = hosts.firstIndex(where: { $0.url == host.url }) else {
                assertionFailure("Attempt to notify a host which is not in the strategy list")
                return
            }

            guard let error else {
                self.hosts[hostIndex].reset()
                return
            }

            if self.isTimeout(error) {
                self.hosts[hostIndex].hasTimedOut()
                return
            }

            if self.isRetryable(error) {
                self.hosts[hostIndex].hasFailed()
                return
            }
        }
    }

    func isRetryable(_ error: Error) -> Bool {
        switch error {
        case let .requestError(error) as AlgoliaError where error is URLError:
            true

        case let .httpError(httpError) as AlgoliaError
            where !httpError.statusCode.belongs(to: .success, .clientError):
            true

        case .badHost as URLRequest.FormatError:
            true

        default:
            false
        }
    }

    func isTimeout(_ error: Error) -> Bool {
        switch error {
        case let .requestError(error as URLError) as AlgoliaError where error.code == .timedOut:
            true

        case let .httpError(error) as AlgoliaError where error.statusCode == .requestTimeout:
            true

        default:
            false
        }
    }

    func canRetry(inCaseOf error: some Error) -> Bool {
        self.isTimeout(error) || self.isRetryable(error)
    }
}

// MARK: CustomDebugStringConvertible

extension AlgoliaRetryStrategy: CustomDebugStringConvertible {
    var debugDescription: String {
        self.hosts.map(\.debugDescription).joined(separator: "\n")
    }
}
