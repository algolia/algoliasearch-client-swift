// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import Core
#endif

public struct DailyRevenue: Codable, JSONEncodable {
    /// Revenue associated with this search, broken-down by currencies.
    public var currencies: [String: CurrenciesValue]
    /// Date in the format YYYY-MM-DD.
    public var date: String

    public init(currencies: [String: CurrenciesValue], date: String) {
        self.currencies = currencies
        self.date = date
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case currencies
        case date
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.currencies, forKey: .currencies)
        try container.encode(self.date, forKey: .date)
    }
}
