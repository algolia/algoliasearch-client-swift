//
//  Logging.swift
//
//
//  Created by Algolia on 20/02/2020.
//

import Foundation
#if os(Linux)
    import Logging

    typealias SwiftLog = Logging.Logger
#else
    import OSLog

    typealias SwiftLog = os.Logger
#endif

public struct Logger {
    static var loggingService: Loggable = {
        var logger: Loggable
        #if os(Linux)
            logger = SwiftLog(label: "com.algolia.searchClientSwift")
        #else
            logger = SwiftLog(subsystem: "com.algolia", category: "searchClientSwift")
        #endif
        return logger
    }()

    @available(*, deprecated, message: "minSeverityLevel is deprecated")
    public static var minSeverityLevel: LogLevel {
        get {
            loggingService.minSeverityLevel
        }

        set {
            loggingService.minSeverityLevel = newValue
        }
    }

    private init() {}

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

#if os(Linux)
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

    extension SwiftLog: Loggable {
        var minSeverityLevel: LogLevel {
            get {
                LogLevel(swiftLogLevel: logLevel)
            }
            set {
                self.logLevel = newValue.swiftLogLevel
            }
        }

        func log(level: LogLevel, message: String) {
            self.log(level: level.swiftLogLevel, SwiftLog.Message(stringLiteral: message), metadata: .none)
        }
    }

#else

    extension LogLevel {
        init(_ type: OSLogType) {
            switch type {
            case .debug:
                self = .debug
            case .info:
                self = .info
            case .error:
                self = .error
            case .fault:
                self = .critical
            default:
                self = .info
            }
        }

        var type: OSLogType {
            switch self {
            case .trace: .info
            case .debug: .debug
            case .info: .info
            case .notice: .info
            case .warning: .info
            case .error: .error
            case .critical: .fault
            }
        }
    }

    extension SwiftLog: Loggable {
        var minSeverityLevel: LogLevel {
            get {
                .init(.default)
            }
            // swiftlint:disable:next unused_setter_value
            set {
                self.log(level: .info, "minSeverityLevel is deprecated")
            }
        }

        func log(level: LogLevel, message: String) {
            self.log(level: level.type, "\(message)")
        }
    }

#endif

protocol Loggable {
    @available(*, deprecated, message: "minSeverityLevel is deprecated")
    var minSeverityLevel: LogLevel { get set }

    func log(level: LogLevel, message: String)
}
