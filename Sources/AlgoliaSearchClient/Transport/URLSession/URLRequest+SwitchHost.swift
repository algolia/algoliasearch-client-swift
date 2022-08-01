//
//  URLRequest+SwitchHost.swift
//  
//
//  Created by Vladislav Fitc on 20/07/2022.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLComponents: Builder {}

extension URLRequest {

  func switchingHost(by host: RetryableHost, withBaseTimeout baseTimeout: TimeInterval) throws -> URLRequest {
    guard let url = url else { throw FormatError.missingURL }
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { throw FormatError.malformedURL(url.absoluteString) }
    guard let updatedURL = components.set(\.host, to: host.url.absoluteString).url else { throw FormatError.badHost(host.url.absoluteString) }
    let updatedTimeout = TimeInterval(host.retryCount + 1) * baseTimeout
    return self
      .set(\.url, to: updatedURL)
      .set(\.timeoutInterval, to: updatedTimeout)
  }

}

public extension URLRequest {

  enum FormatError: LocalizedError {
    case missingURL
    case malformedURL(String)
    case badHost(String)
    case invalidPath(String)

    public var errorDescription: String? {
      let contactUs = "Please contact support@algolia.com if this problem occurs."
      switch self {
      case .badHost(let host):
        return "Bad host: \(host). Will retry with next host. " + contactUs
      case .malformedURL(let url):
        return "Command's request URL is malformed: \(url). " + contactUs
      case .missingURL:
        return "Command's request doesn't contain URL. " + contactUs
      case .invalidPath(let path):
        return "Invalid path: \(path)"
      }
    }
  }

}
