//
//  Logging.swift
//  
//
//  Created by Vladislav Fitc on 20/02/2020.
//

import Foundation
#if os(Linux)
import Logging
typealias SwiftLog = Logging.Logger
#else
#endif
import OSLog
typealias SwiftLog = os.Logger

public struct Logger {

  static var loggingService: Loggable = {
    var logger: Loggable
    #if os(Linux)
    logger = SwiftLog(label: "com.algolia.searchClientSwift")
    logger.logLevel = .info
    #else
    logger = SwiftLog(subsystem: "com.algolia", category: "searchClientSwift")
    #endif
    print("Algolia Search Client Swift: Default minimal log severity level is info. Change Logger.minLogServerityLevel value if you want to change it.")
    return logger
  }()

  public static var minSeverityLevel: LogLevel {
    get {
      return loggingService.minSeverityLevel
    }

    set {
      loggingService.minSeverityLevel = newValue
    }
  }

  private init() {}

  static func trace(_ message: String) {
    loggingService.log(level: .trace, message: message)
  }

  static func debug(_ message: String) {
    loggingService.log(level: .debug, message: message)
  }

  static func info(_ message: String) {
    loggingService.log(level: .info, message: message)
  }

  static func notice(_ message: String) {
    loggingService.log(level: .notice, message: message)
  }

  static func warning(_ message: String) {
    loggingService.log(level: .warning, message: message)
  }

  static func error(_ message: String) {
    loggingService.log(level: .error, message: message)
  }

  static func critical(_ message: String) {
    loggingService.log(level: .critical, message: message)
  }

}

public enum LogLevel {
  case trace, debug, info, notice, warning, error, critical
}

extension Logger {

  static func error(prefix: String = "", _ error: Error) {
    let errorMessage: String
    if let decodingError = error as? DecodingError {
      errorMessage = decodingError.prettyDescription
    } else {
      errorMessage = "\(error)"
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
    case .trace: return .trace
    case .debug: return .debug
    case .info: return .info
    case .notice: return .notice
    case .warning: return .warning
    case .error: return .error
    case .critical: return .critical
    }
  }

}

extension SwiftLog: Loggable {

  var minSeverityLevel: LogLevel {
    get {
      return LogLevel(swiftLogLevel: logLevel)
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
    case .trace: return .info
    case .debug: return .debug
    case .info: return .info
    case .notice: return .info
    case .warning: return .info
    case .error: return .error
    case .critical: return .fault
    }
  }
  
}

extension SwiftLog: Loggable {
  
  var minSeverityLevel: LogLevel {
    get {
      .init(.default)
    }
    set {
      
    }
  }
  
  func log(level: LogLevel, message: String) {
    log(level: level.type, "\(message)")
  }
  
}

#endif

protocol Loggable {

  var minSeverityLevel: LogLevel { get set }

  func log(level: LogLevel, message: String)

}

