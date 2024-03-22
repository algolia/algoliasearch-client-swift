// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import Core
#endif

public struct GetAverageClickPositionResponse: Codable, JSONEncodable {
    /// Average position of a clicked search result in the list of search results. If null, Algolia didn't receive any
    /// search requests with `clickAnalytics` set to true.
    public var average: Double?
    /// Number of clicks associated with this search.
    public var clickCount: Int
    /// Daily average click positions.
    public var dates: [DailyAverageClicks]

    public init(average: Double?, clickCount: Int, dates: [DailyAverageClicks]) {
        self.average = average
        self.clickCount = clickCount
        self.dates = dates
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case average
        case clickCount
        case dates
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.average, forKey: .average)
        try container.encode(self.clickCount, forKey: .clickCount)
        try container.encode(self.dates, forKey: .dates)
    }
}
