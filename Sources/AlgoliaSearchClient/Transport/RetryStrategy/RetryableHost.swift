//
//  RetryableHost.swift
//  
//
//  Created by Vladislav Fitc on 19/02/2020.
//

import Foundation

public struct RetryableHost {

  /// The url to target.
  public let url: URL

  let supportedCallTypes: CallTypeSupport
  var isUp: Bool
  var lastUpdated: Date
  var retryCount: Int

  init(url: URL, callType: CallTypeSupport = .universal) {
    self.url = url
    self.supportedCallTypes = callType
    self.isUp = true
    self.lastUpdated = .init()
    self.retryCount = 0
  }

  public func supports(_ callType: CallType) -> Bool {
    switch callType {
    case .read:
      return supportedCallTypes.contains(.read)
    case .write:
      return supportedCallTypes.contains(.write)
    }
  }

  mutating func reset() {
    lastUpdated = .init()
    isUp = true
    retryCount = 0
  }

  mutating func hasTimedOut() {
    isUp = true
    lastUpdated = .init()
    retryCount += 1
  }

  mutating func hasFailed() {
    isUp = false
    lastUpdated = .init()
  }

}

extension RetryableHost {

  struct CallTypeSupport: OptionSet {
    let rawValue: Int
    static let read = CallTypeSupport(rawValue: 1 << 0)
    static let write = CallTypeSupport(rawValue: 1 << 1)
    static let universal: CallTypeSupport = [.read, .write]
  }

}

extension RetryableHost.CallTypeSupport: CustomDebugStringConvertible {

  var debugDescription: String {
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

extension RetryableHost: CustomDebugStringConvertible {

  public var debugDescription: String {
    return "Host \(supportedCallTypes.debugDescription) \(url) up: \(isUp) retry count: \(retryCount) updated: \(lastUpdated)"
  }

}

extension RetryableHost {

  func timeout(requestOptions: RequestOptions? = nil, default: TimeInterval) -> TimeInterval {
    let callType: CallType = supportedCallTypes.contains(.write) ? .write : .read
    let unitTimeout = requestOptions?.timeout(for: callType) ?? `default`
    let multiplier = retryCount + 1
    return TimeInterval(multiplier) * unitTimeout
  }

}

extension Array where Element == RetryableHost {

  /** Reset all hosts down for more than specified interval.
  */
  public mutating func resetExpired(expirationDelay: TimeInterval) {
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

  public mutating func resetAll(for callType: CallType) {
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
