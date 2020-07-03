//
//  SecuredAPIKeyRestriction.swift
//  
//
//  Created by Vladislav Fitc on 01/06/2020.
//

import Foundation

/// Secured Api Key restrictions
public struct SecuredAPIKeyRestriction {

  /// Search query parameters
  public var query: Query?

  /// List of index names that can be queried.
  public var restrictIndices: [IndexName]?

  /// IPv4 network allowed to use the generated key. This is used for more protection against API key leaking and reuse.
  public var restrictSources: [String]?

  /// A Unix timestamp used to define the expiration date of the API key.
  public var validUntil: TimeInterval?

  /// Specify a user identifier. This is often used with rate limits.
  public var userToken: UserToken?

  public init(query: Query? = nil,
              restrictIndices: [IndexName]? = nil,
              restrictSources: [String]? = nil,
              validUntil: TimeInterval? = nil,
              userToken: UserToken? = nil) {
    self.query = query
    self.restrictIndices = restrictIndices
    self.restrictSources = restrictSources
    self.validUntil = validUntil
    self.userToken = userToken
  }

}

extension SecuredAPIKeyRestriction: Builder {}

extension SecuredAPIKeyRestriction: URLEncodable {

  enum CodingKeys: String {
    case restrictIndices
    case restrictSources
    case userToken
    case validUntil
  }

  public var urlEncodedString: String {
    var urlEncoder = Query.URLEncoder<CodingKeys>()
    urlEncoder.set(restrictIndices, for: .restrictIndices)
    urlEncoder.set(restrictSources, for: .restrictSources)
    urlEncoder.set(userToken, for: .userToken)
    if let validUntil = validUntil {
      urlEncoder.set(Int(validUntil), for: .validUntil)
    }
    return [query?.urlEncodedString, urlEncoder.encode()]
      .compactMap { $0 }
      .filter { !$0.isEmpty }
      .joined(separator: "&")
  }

}
