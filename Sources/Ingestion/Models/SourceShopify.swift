// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

public struct SourceShopify: Codable, JSONEncodable {
    /// Feature flags for the Shopify source.
    public var featureFlags: [String: AnyCodable]?
    /// URL of the Shopify store.
    public var shopURL: String

    public init(featureFlags: [String: AnyCodable]? = nil, shopURL: String) {
        self.featureFlags = featureFlags
        self.shopURL = shopURL
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case featureFlags
        case shopURL
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.featureFlags, forKey: .featureFlags)
        try container.encode(self.shopURL, forKey: .shopURL)
    }
}

extension SourceShopify: Equatable {
    public static func ==(lhs: SourceShopify, rhs: SourceShopify) -> Bool {
        lhs.featureFlags == rhs.featureFlags &&
            lhs.shopURL == rhs.shopURL
    }
}

extension SourceShopify: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.featureFlags?.hashValue)
        hasher.combine(self.shopURL.hashValue)
    }
}
