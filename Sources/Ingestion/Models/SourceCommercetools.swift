// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

public struct SourceCommercetools: Codable, JSONEncodable {
    public var storeKeys: [String]?
    /// Locales for your commercetools stores.
    public var locales: [String]?
    public var url: String
    public var projectKey: String
    /// Whether a fallback value is stored in the Algolia record if there's no inventory information about the product.
    public var fallbackIsInStockValue: Bool?
    public var customFields: CommercetoolsCustomFields?

    public init(
        storeKeys: [String]? = nil,
        locales: [String]? = nil,
        url: String,
        projectKey: String,
        fallbackIsInStockValue: Bool? = nil,
        customFields: CommercetoolsCustomFields? = nil
    ) {
        self.storeKeys = storeKeys
        self.locales = locales
        self.url = url
        self.projectKey = projectKey
        self.fallbackIsInStockValue = fallbackIsInStockValue
        self.customFields = customFields
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case storeKeys
        case locales
        case url
        case projectKey
        case fallbackIsInStockValue
        case customFields
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.storeKeys, forKey: .storeKeys)
        try container.encodeIfPresent(self.locales, forKey: .locales)
        try container.encode(self.url, forKey: .url)
        try container.encode(self.projectKey, forKey: .projectKey)
        try container.encodeIfPresent(self.fallbackIsInStockValue, forKey: .fallbackIsInStockValue)
        try container.encodeIfPresent(self.customFields, forKey: .customFields)
    }
}

extension SourceCommercetools: Equatable {
    public static func ==(lhs: SourceCommercetools, rhs: SourceCommercetools) -> Bool {
        lhs.storeKeys == rhs.storeKeys &&
            lhs.locales == rhs.locales &&
            lhs.url == rhs.url &&
            lhs.projectKey == rhs.projectKey &&
            lhs.fallbackIsInStockValue == rhs.fallbackIsInStockValue &&
            lhs.customFields == rhs.customFields
    }
}

extension SourceCommercetools: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.storeKeys?.hashValue)
        hasher.combine(self.locales?.hashValue)
        hasher.combine(self.url.hashValue)
        hasher.combine(self.projectKey.hashValue)
        hasher.combine(self.fallbackIsInStockValue?.hashValue)
        hasher.combine(self.customFields?.hashValue)
    }
}
