// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import Core
#endif

public struct DailyAverageClicks: Codable, JSONEncodable {
    /// Average position of a clicked search result in the list of search results. If null, Algolia didn't receive any
    /// search requests with `clickAnalytics` set to true.
    public var average: Double?
    /// Number of clicks associated with this search.
    public var clickCount: Int
    /// Date in the format YYYY-MM-DD.
    public var date: String

    public init(average: Double?, clickCount: Int, date: String) {
        self.average = average
        self.clickCount = clickCount
        self.date = date
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case average
        case clickCount
        case date
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.average, forKey: .average)
        try container.encode(self.clickCount, forKey: .clickCount)
        try container.encode(self.date, forKey: .date)
    }
}
