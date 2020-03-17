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
  
  /// Whether this host should be used for CallType.read or CallType.write requests.
  public let callType: CallType?
  var isUp: Bool
  var lastUpdated: Date
  var retryCount: Int
  
  init(url: URL, callType: CallType? = nil) {
    self.url = url
    self.callType = callType
    self.isUp = true
    self.lastUpdated = .init()
    self.retryCount = 0
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

extension RetryableHost: CustomDebugStringConvertible {
  
  public var debugDescription: String {
    return "Host \(callType?.description ?? "nil") \(url) up: \(isUp) retry count: \(retryCount) updated: \(lastUpdated)"
  }
  
}

extension RetryableHost {
  
  func timeout(requestOptions: RequestOptions? = nil) -> TimeInterval {
    let callType = self.callType ?? .read
    let unitTimeout = requestOptions?.timeout(for: callType) ?? DefaultConfiguration.default.timeout(for: callType)
    let multiplier = retryCount + 1
    return TimeInterval(multiplier) * unitTimeout
  }
  
}

extension Array where Element == RetryableHost {
  
  /** Reset all hosts down for more than specified interval.
   - default interval is 5 minutes
   */
  public mutating func resetExpired(expirationDelay: TimeInterval = .minutes(5)) {
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
      if mutableHost.callType == callType || mutableHost.callType == nil {
        mutableHost.reset()
      }
      updatedHosts.append(mutableHost)
    }
    self = updatedHosts
  }
    
  public init(forApplicationID appID: ApplicationID) {
    let hostSuffixes: [(suffix: String, callType: CallType?)] = [
      ("-dsn.algolia.net", .read),
      (".algolia.net", .write),
      ("-1.algolianet.com", nil),
      ("-2.algolianet.com", nil),
      ("-3.algolianet.com", nil),
    ]
    self = hostSuffixes.map {
      let url = URL(string: "\(appID.rawValue)\($0.suffix)")!
      return RetryableHost(url: url, callType: $0.callType)
    }
  }
  
}

