// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

public struct GetNoResultsRateResponse: Codable, JSONEncodable {
    /// No results rate, calculated as number of searches with zero results divided by the total number of searches.
    public var rate: Double
    /// Number of searches.
    public var count: Int
    /// Number of searches without any results.
    public var noResultCount: Int
    /// Daily no results rates.
    public var dates: [DailyNoResultsRates]

    public init(rate: Double, count: Int, noResultCount: Int, dates: [DailyNoResultsRates]) {
        self.rate = rate
        self.count = count
        self.noResultCount = noResultCount
        self.dates = dates
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case rate
        case count
        case noResultCount
        case dates
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.rate, forKey: .rate)
        try container.encode(self.count, forKey: .count)
        try container.encode(self.noResultCount, forKey: .noResultCount)
        try container.encode(self.dates, forKey: .dates)
    }
}

extension GetNoResultsRateResponse: Equatable {
    public static func ==(lhs: GetNoResultsRateResponse, rhs: GetNoResultsRateResponse) -> Bool {
        lhs.rate == rhs.rate &&
            lhs.count == rhs.count &&
            lhs.noResultCount == rhs.noResultCount &&
            lhs.dates == rhs.dates
    }
}

extension GetNoResultsRateResponse: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.rate.hashValue)
        hasher.combine(self.count.hashValue)
        hasher.combine(self.noResultCount.hashValue)
        hasher.combine(self.dates.hashValue)
    }
}
