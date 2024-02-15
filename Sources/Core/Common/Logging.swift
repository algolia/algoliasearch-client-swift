//
//  Logging.swift
//
//
//  Created by Algolia on 15/12/2023.
//

import Foundation
import Logging

typealias SwiftLog = Logging.Logger

// MARK: - Logger

public struct Logger {
    // MARK: Lifecycle

    private init() {}

    // MARK: Public

    public static var loggingService: Loggable = {
        var swiftLog = SwiftLog(label: "com.algolia.searchClientSwift")
        print(
            "Algolia Search Client Swift: Default minimal log severity level is info. Change Logger.minLogServerityLevel value if you want to change it."
        )
        swiftLog.logLevel = .info
        return swiftLog
    }()

    public static var minSeverityLevel: LogLevel {
        get {
            loggingService.minSeverityLevel
        }

        set {
            loggingService.minSeverityLevel = newValue
        }
    }

    // MARK: Internal

    static func trace(_ message: String) {
        self.loggingService.log(level: .trace, message: message)
    }

    static func debug(_ message: String) {
        self.loggingService.log(level: .debug, message: message)
    }

    static func info(_ message: String) {
        self.loggingService.log(level: .info, message: message)
    }

    static func notice(_ message: String) {
        self.loggingService.log(level: .notice, message: message)
    }

    static func warning(_ message: String) {
        self.loggingService.log(level: .warning, message: message)
    }

    static func error(_ message: String) {
        self.loggingService.log(level: .error, message: message)
    }

    static func critical(_ message: String) {
        self.loggingService.log(level: .critical, message: message)
    }
}

// MARK: - LogLevel

public enum LogLevel {
    case trace
    case debug
    case info
    case notice
    case warning
    case error
    case critical
}

extension Logger {
    static func error(prefix: String = "", _ error: Error) {
        let errorMessage: String =
            if let decodingError = error as? DecodingError {
                decodingError.prettyDescription
            } else {
                "\(error)"
            }
        self.error("\(prefix) \(errorMessage)")
    }
}

extension LogLevel {
    init(swiftLogLevel: SwiftLog.Level) {
        switch swiftLogLevel {
        case .trace: self = .trace
        case .debug: self = .debug
        case .info: self = .info
        case .notice: self = .notice
        case .warning: self = .warning
        case .error: self = .error
        case .critical: self = .critical
        }
    }

    var swiftLogLevel: SwiftLog.Level {
        switch self {
        case .trace: .trace
        case .debug: .debug
        case .info: .info
        case .notice: .notice
        case .warning: .warning
        case .error: .error
        case .critical: .critical
        }
    }
}

// MARK: - Loggable

public protocol Loggable {
    var minSeverityLevel: LogLevel { get set }

    func log(level: LogLevel, message: String)
}

// MARK: - SwiftLog + Loggable

extension SwiftLog: Loggable {
    public var minSeverityLevel: LogLevel {
        get {
            LogLevel(swiftLogLevel: logLevel)
        }
        set {
            logLevel = newValue.swiftLogLevel
        }
    }

    public func log(level: LogLevel, message: String) {
        self.log(level: level.swiftLogLevel, SwiftLog.Message(stringLiteral: message), metadata: .none)
    }
}
