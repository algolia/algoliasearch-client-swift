//
//  BaseConfiguration.swift
//
//
//  Created by Algolia on 20/02/2020.
//

import Foundation

// MARK: - BaseConfiguration

public protocol BaseConfiguration {
    /// The timeout for each request when performing write operations (POST, PUT ..).
    var writeTimeout: TimeInterval { get }

    /// The timeout for each request when performing read operations (GET).
    var readTimeout: TimeInterval { get }

    /// LogLevel to display in the console.
    var logLevel: LogLevel { get }

    /// List of hosts and back-up host used to perform a custom retry logic.
    var hosts: [RetryableHost] { get }

    /// Default headers that should be applied to every request.
    var defaultHeaders: [String: String]? { get set }

    /// Compression type
    var compression: CompressionAlgorithm { get }

    /// Whether the transport sends the Request-ID tracing header. Defaulted to false by a
    /// protocol extension; only the generated configurations of the APIs that support it
    /// opt in. The requirement must be declared here: without it, reads through the
    /// protocol existential would statically dispatch to the extension default and ignore
    /// the conforming type's value.
    var requestIDEnabled: Bool { get }

    /// How many times a 429 is waited out on the same host. Default 3; 0 fails on the first 429.
    var maxRateLimitRetries: Int { get }
}

public extension BaseConfiguration {
    /// Whether the transport sends a Request-ID header, minted once per call and reused
    /// across its retry attempts, so that Algolia support can tie the attempts of one
    /// request together. Only the generated configurations of the APIs that support it
    /// (search, recommend, composition) opt in; a Request-ID supplied through the request
    /// options or the default headers is never overwritten.
    var requestIDEnabled: Bool {
        false
    }

    /// How many times a 429 is waited out on the same host. Default 3; 0 fails on the first 429.
    var maxRateLimitRetries: Int {
        RateLimitRetry.defaultMaxRetries
    }
}

extension BaseConfiguration {
    func timeout(for callType: CallType) -> TimeInterval {
        switch callType {
        case .read:
            readTimeout
        case .write:
            writeTimeout
        }
    }
}

// MARK: - DefaultConfiguration

public struct DefaultConfiguration: BaseConfiguration {
    public static let `default`: BaseConfiguration = DefaultConfiguration()

    public let writeTimeout: TimeInterval = 30
    public let readTimeout: TimeInterval = 5
    public let logLevel: LogLevel = .info
    public var defaultHeaders: [String: String]? = [:]
    public var hosts: [RetryableHost] = []
    public let compression: CompressionAlgorithm = .none
    public let maxRateLimitRetries: Int = RateLimitRetry.defaultMaxRetries
}
