// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Core
import Foundation
#if canImport(AnyCodable)
    import AnyCodable
#endif

public struct ClickThroughRateEvent: Codable, JSONEncodable, Hashable {
    static let rateRule = NumericRule<Double>(minimum: 0, exclusiveMinimum: false, maximum: 1, exclusiveMaximum: false, multipleOf: nil)
    /** [Click-through rate (CTR)](https://www.algolia.com/doc/guides/search-analytics/concepts/metrics/#click-through-rate).  */
    public var rate: Double
    /** Number of click events. */
    public var clickCount: Int
    /** Number of tracked searches. This is the number of search requests where the `clickAnalytics` parameter is `true`. */
    public var trackedSearchCount: Int
    /** Date of the event in the format YYYY-MM-DD. */
    public var date: String

    public init(rate: Double, clickCount: Int, trackedSearchCount: Int, date: String) {
        self.rate = rate
        self.clickCount = clickCount
        self.trackedSearchCount = trackedSearchCount
        self.date = date
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case rate
        case clickCount
        case trackedSearchCount
        case date
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rate, forKey: .rate)
        try container.encode(clickCount, forKey: .clickCount)
        try container.encode(trackedSearchCount, forKey: .trackedSearchCount)
        try container.encode(date, forKey: .date)
    }
}