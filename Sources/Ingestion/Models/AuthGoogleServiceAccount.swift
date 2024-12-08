// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

/// Credentials for authenticating with a Google service account, such as BigQuery.
public struct AuthGoogleServiceAccount: Codable, JSONEncodable {
    /// Email address of the Google service account.
    public var clientEmail: String
    /// Private key of the Google service account. This field is `null` in the API response.
    public var privateKey: String

    public init(clientEmail: String, privateKey: String) {
        self.clientEmail = clientEmail
        self.privateKey = privateKey
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case clientEmail
        case privateKey
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.clientEmail, forKey: .clientEmail)
        try container.encode(self.privateKey, forKey: .privateKey)
    }
}

extension AuthGoogleServiceAccount: Equatable {
    public static func ==(lhs: AuthGoogleServiceAccount, rhs: AuthGoogleServiceAccount) -> Bool {
        lhs.clientEmail == rhs.clientEmail &&
            lhs.privateKey == rhs.privateKey
    }
}

extension AuthGoogleServiceAccount: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.clientEmail.hashValue)
        hasher.combine(self.privateKey.hashValue)
    }
}
