//
//  SearchClient+SecuredAPIKey.swift
//  
//
//  Created by Vladislav Fitc on 02/06/2020.
//

import Foundation

public extension SearchClient {

  func generateSecuredApiKey(parentApiKey: APIKey,
                             with restriction: SecuredAPIKeyRestriction) -> APIKey {
    let queryParams = restriction.urlEncodedString
    let hash = queryParams.hmac256(withKey: parentApiKey.rawValue)
    return APIKey(rawValue: "\(hash)\(queryParams)".toBase64())
  }

  func getSecuredApiKeyRemainingValidity(_ securedAPIKey: APIKey) -> TimeInterval? {
    guard let rawDecodedAPIKey = securedAPIKey.rawValue.fromBase64() else { return nil }
    let prefix = "validUntil="
    guard let range = rawDecodedAPIKey.range(of: "\(prefix)\\d+", options: .regularExpression) else { return nil }
    let validitySubstring = String(rawDecodedAPIKey[range].dropFirst(prefix.count))
    guard let timestamp = TimeInterval(String(validitySubstring)) else { return nil }
    let timestampDate = Date(timeIntervalSince1970: timestamp)
    return timestampDate.timeIntervalSince1970 - Date().timeIntervalSince1970
  }
}
