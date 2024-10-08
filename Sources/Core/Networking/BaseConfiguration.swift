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
}
