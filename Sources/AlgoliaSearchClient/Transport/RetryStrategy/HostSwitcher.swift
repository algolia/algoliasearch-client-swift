//
//  HostSwitcher.swift
//  
//
//  Created by Vladislav Fitc on 02/04/2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLComponents: Builder {}

struct HostSwitcher {

  static func switchHost(in request: URLRequest, by host: RetryableHost, timeout: TimeInterval) throws -> URLRequest {
    guard let url = request.url else { throw Error.missingURL }
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { throw Error.malformedURL(url.absoluteString) }
    guard let updatedURL = components.set(\.host, to: host.url.absoluteString).url else { throw Error.badHost(host.url.absoluteString) }
    let updatedTimeout = TimeInterval(host.retryCount + 1) * timeout
    return request
      .set(\.url, to: updatedURL)
      .set(\.timeoutInterval, to: updatedTimeout)
  }

}

extension URLRequest {

  func setting(_ host: RetryableHost, timeout: TimeInterval) throws -> URLRequest {
    return try HostSwitcher.switchHost(in: self, by: host, timeout: timeout)
  }

}

extension HostSwitcher {

  enum Error: LocalizedError {
    case missingURL
    case malformedURL(String)
    case badHost(String)

    var errorDescription: String? {
      switch self {
      case .badHost(let host):
        return "Bad host: \(host). Will retry with next host. Please contact support@algolia.com if this problem occurs."
      case .malformedURL(let url):
        return "Command's request URL is malformed: \(url). Please contact support@algolia.com if this problem occurs."
      case .missingURL:
        return "Command's request doesn't contain URL. Please contact support@algolia.com if this problem occurs."
      }
    }
  }

}
