//
//  RetryableHost.swift
//
//
//  Created by Algolia on 19/02/2020.
//

import Foundation

// MARK: - RetryableHost

public struct RetryableHost {
    // MARK: Lifecycle

    public init(url: URL) {
        self.init(url: url, callType: .universal)
    }

    public init(url: URL, callType: CallTypeSupport = .universal) {
        self.url = url
        self.supportedCallTypes = callType
        self.isUp = true
        self.lastUpdated = .init()
        self.retryCount = 0
    }

    // MARK: Public

    /// The url to target.
    public let url: URL

    public func supports(_ callType: CallType) -> Bool {
        switch callType {
        case .read:
            self.supportedCallTypes.contains(.read)
        case .write:
            self.supportedCallTypes.contains(.write)
        }
    }

    // MARK: Internal

    let supportedCallTypes: CallTypeSupport
    var isUp: Bool
    var lastUpdated: Date
    var retryCount: Int

    mutating func reset() {
        self.lastUpdated = .init()
        self.isUp = true
        self.retryCount = 0
    }

    mutating func hasTimedOut() {
        self.isUp = true
        self.lastUpdated = .init()
        self.retryCount += 1
    }

    mutating func hasFailed() {
        self.isUp = false
        self.lastUpdated = .init()
    }
}

// MARK: RetryableHost.CallTypeSupport

public extension RetryableHost {
    struct CallTypeSupport: OptionSet {
        // MARK: Lifecycle

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        // MARK: Public

        public static let read = CallTypeSupport(rawValue: 1 << 0)
        public static let write = CallTypeSupport(rawValue: 1 << 1)
        public static let universal: CallTypeSupport = [.read, .write]

        public let rawValue: Int
    }
}

// MARK: - RetryableHost.CallTypeSupport + CustomDebugStringConvertible

extension RetryableHost.CallTypeSupport: CustomDebugStringConvertible {
    public var debugDescription: String {
        var components: [String] = []
        if contains(.read) {
            components.append("read")
        }
        if contains(.write) {
            components.append("write")
        }
        return "[\(components.joined(separator: ", "))]"
    }
}

// MARK: - RetryableHost + CustomDebugStringConvertible

extension RetryableHost: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Host \(self.supportedCallTypes.debugDescription) \(self.url) up: \(self.isUp) retry count: \(self.retryCount) updated: \(self.lastUpdated)"
    }
}

public extension [RetryableHost] {
    /// Reset all hosts down for more than specified interval.
    mutating func resetExpired(expirationDelay: TimeInterval) {
        var updatedHosts: [RetryableHost] = []
        for host in self {
            var mutableHost = host
            let timeDelayExpired = Date().timeIntervalSince(host.lastUpdated)
            if timeDelayExpired > expirationDelay {
                mutableHost.reset()
            }
            updatedHosts.append(mutableHost)
        }
        self = updatedHosts
    }

    mutating func resetAll(for callType: CallType) {
        var updatedHosts: [RetryableHost] = []
        for host in self {
            var mutableHost = host
            if mutableHost.supports(callType) {
                mutableHost.reset()
            }
            updatedHosts.append(mutableHost)
        }
        self = updatedHosts
    }
}
