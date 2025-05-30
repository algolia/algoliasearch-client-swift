// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import Core
#endif

public struct DailyAddToCartRates: Codable, JSONEncodable {
    /// Add-to-cart rate: calculated as the number of tracked searches with at least one add-to-cart event divided by
    /// the number of tracked searches. If null, Algolia didn't receive any search requests with `clickAnalytics` set to
    /// true.
    public var rate: Double?
    /// Number of tracked searches. Tracked searches are search requests where the `clickAnalytics` parameter is true.
    public var trackedSearchCount: Int
    /// Number of add-to-cart events from this search.
    public var addToCartCount: Int
    /// Date in the format YYYY-MM-DD.
    public var date: String

    public init(rate: Double?, trackedSearchCount: Int, addToCartCount: Int, date: String) {
        self.rate = rate
        self.trackedSearchCount = trackedSearchCount
        self.addToCartCount = addToCartCount
        self.date = date
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case rate
        case trackedSearchCount
        case addToCartCount
        case date
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.rate, forKey: .rate)
        try container.encode(self.trackedSearchCount, forKey: .trackedSearchCount)
        try container.encode(self.addToCartCount, forKey: .addToCartCount)
        try container.encode(self.date, forKey: .date)
    }
}

extension DailyAddToCartRates: Equatable {
    public static func ==(lhs: DailyAddToCartRates, rhs: DailyAddToCartRates) -> Bool {
        lhs.rate == rhs.rate &&
            lhs.trackedSearchCount == rhs.trackedSearchCount &&
            lhs.addToCartCount == rhs.addToCartCount &&
            lhs.date == rhs.date
    }
}

extension DailyAddToCartRates: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.rate.hashValue)
        hasher.combine(self.trackedSearchCount.hashValue)
        hasher.combine(self.addToCartCount.hashValue)
        hasher.combine(self.date.hashValue)
    }
}
