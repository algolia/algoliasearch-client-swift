// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

public struct Variant: Codable, JSONEncodable {
    /// Number of add-to-cart events for this variant.
    public var addToCartCount: Int
    /// [Add-to-cart rate](https://www.algolia.com/doc/guides/search-analytics/concepts/metrics/#add-to-cart-rate) for
    /// this variant.
    public var addToCartRate: Double?
    /// [Average click position](https://www.algolia.com/doc/guides/search-analytics/concepts/metrics/#click-position)
    /// for this variant.
    public var averageClickPosition: Int?
    /// Number of click events for this variant.
    public var clickCount: Int
    /// [Click-through rate](https://www.algolia.com/doc/guides/search-analytics/concepts/metrics/#click-through-rate)
    /// for this variant.
    public var clickThroughRate: Double?
    /// Number of click events for this variant.
    public var conversionCount: Int
    /// [Conversion rate](https://www.algolia.com/doc/guides/search-analytics/concepts/metrics/#conversion-rate) for
    /// this variant.
    public var conversionRate: Double?
    /// A/B test currencies.
    public var currencies: [String: Currency]?
    /// Description for this variant.
    public var description: String?
    /// Estimated number of searches required to achieve the desired statistical significance.  The A/B test
    /// configuration must include a `mininmumDetectableEffect` setting for this number to be included in the response.
    public var estimatedSampleSize: Int?
    public var filterEffects: FilterEffects?
    /// Index name of the A/B test variant (case-sensitive).
    public var index: String
    /// Number of [searches without
    /// results](https://www.algolia.com/doc/guides/search-analytics/concepts/metrics/#searches-without-results) for
    /// this variant.
    public var noResultCount: Int?
    /// Number of purchase events for this variant.
    public var purchaseCount: Int
    /// [Purchase rate](https://www.algolia.com/doc/guides/search-analytics/concepts/metrics/#purchase-rate) for this
    /// variant.
    public var purchaseRate: Double?
    /// Number of searches for this variant.
    public var searchCount: Int?
    /// Number of tracked searches. Tracked searches are search requests where the `clickAnalytics` parameter is true.
    public var trackedSearchCount: Int?
    /// Percentage of search requests each variant receives.
    public var trafficPercentage: Int
    /// Number of users that made searches to this variant.
    public var userCount: Int?
    /// Number of users that made tracked searches to this variant.
    public var trackedUserCount: Int?

    public init(
        addToCartCount: Int,
        addToCartRate: Double? = nil,
        averageClickPosition: Int? = nil,
        clickCount: Int,
        clickThroughRate: Double? = nil,
        conversionCount: Int,
        conversionRate: Double? = nil,
        currencies: [String: Currency]? = nil,
        description: String? = nil,
        estimatedSampleSize: Int? = nil,
        filterEffects: FilterEffects? = nil,
        index: String,
        noResultCount: Int?,
        purchaseCount: Int,
        purchaseRate: Double? = nil,
        searchCount: Int?,
        trackedSearchCount: Int? = nil,
        trafficPercentage: Int,
        userCount: Int?,
        trackedUserCount: Int?
    ) {
        self.addToCartCount = addToCartCount
        self.addToCartRate = addToCartRate
        self.averageClickPosition = averageClickPosition
        self.clickCount = clickCount
        self.clickThroughRate = clickThroughRate
        self.conversionCount = conversionCount
        self.conversionRate = conversionRate
        self.currencies = currencies
        self.description = description
        self.estimatedSampleSize = estimatedSampleSize
        self.filterEffects = filterEffects
        self.index = index
        self.noResultCount = noResultCount
        self.purchaseCount = purchaseCount
        self.purchaseRate = purchaseRate
        self.searchCount = searchCount
        self.trackedSearchCount = trackedSearchCount
        self.trafficPercentage = trafficPercentage
        self.userCount = userCount
        self.trackedUserCount = trackedUserCount
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case addToCartCount
        case addToCartRate
        case averageClickPosition
        case clickCount
        case clickThroughRate
        case conversionCount
        case conversionRate
        case currencies
        case description
        case estimatedSampleSize
        case filterEffects
        case index
        case noResultCount
        case purchaseCount
        case purchaseRate
        case searchCount
        case trackedSearchCount
        case trafficPercentage
        case userCount
        case trackedUserCount
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.addToCartCount, forKey: .addToCartCount)
        try container.encodeIfPresent(self.addToCartRate, forKey: .addToCartRate)
        try container.encodeIfPresent(self.averageClickPosition, forKey: .averageClickPosition)
        try container.encode(self.clickCount, forKey: .clickCount)
        try container.encodeIfPresent(self.clickThroughRate, forKey: .clickThroughRate)
        try container.encode(self.conversionCount, forKey: .conversionCount)
        try container.encodeIfPresent(self.conversionRate, forKey: .conversionRate)
        try container.encodeIfPresent(self.currencies, forKey: .currencies)
        try container.encodeIfPresent(self.description, forKey: .description)
        try container.encodeIfPresent(self.estimatedSampleSize, forKey: .estimatedSampleSize)
        try container.encodeIfPresent(self.filterEffects, forKey: .filterEffects)
        try container.encode(self.index, forKey: .index)
        try container.encode(self.noResultCount, forKey: .noResultCount)
        try container.encode(self.purchaseCount, forKey: .purchaseCount)
        try container.encodeIfPresent(self.purchaseRate, forKey: .purchaseRate)
        try container.encode(self.searchCount, forKey: .searchCount)
        try container.encodeIfPresent(self.trackedSearchCount, forKey: .trackedSearchCount)
        try container.encode(self.trafficPercentage, forKey: .trafficPercentage)
        try container.encode(self.userCount, forKey: .userCount)
        try container.encode(self.trackedUserCount, forKey: .trackedUserCount)
    }
}

extension Variant: Equatable {
    public static func ==(lhs: Variant, rhs: Variant) -> Bool {
        lhs.addToCartCount == rhs.addToCartCount &&
            lhs.addToCartRate == rhs.addToCartRate &&
            lhs.averageClickPosition == rhs.averageClickPosition &&
            lhs.clickCount == rhs.clickCount &&
            lhs.clickThroughRate == rhs.clickThroughRate &&
            lhs.conversionCount == rhs.conversionCount &&
            lhs.conversionRate == rhs.conversionRate &&
            lhs.currencies == rhs.currencies &&
            lhs.description == rhs.description &&
            lhs.estimatedSampleSize == rhs.estimatedSampleSize &&
            lhs.filterEffects == rhs.filterEffects &&
            lhs.index == rhs.index &&
            lhs.noResultCount == rhs.noResultCount &&
            lhs.purchaseCount == rhs.purchaseCount &&
            lhs.purchaseRate == rhs.purchaseRate &&
            lhs.searchCount == rhs.searchCount &&
            lhs.trackedSearchCount == rhs.trackedSearchCount &&
            lhs.trafficPercentage == rhs.trafficPercentage &&
            lhs.userCount == rhs.userCount &&
            lhs.trackedUserCount == rhs.trackedUserCount
    }
}

extension Variant: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.addToCartCount.hashValue)
        hasher.combine(self.addToCartRate?.hashValue)
        hasher.combine(self.averageClickPosition?.hashValue)
        hasher.combine(self.clickCount.hashValue)
        hasher.combine(self.clickThroughRate?.hashValue)
        hasher.combine(self.conversionCount.hashValue)
        hasher.combine(self.conversionRate?.hashValue)
        hasher.combine(self.currencies?.hashValue)
        hasher.combine(self.description?.hashValue)
        hasher.combine(self.estimatedSampleSize?.hashValue)
        hasher.combine(self.filterEffects?.hashValue)
        hasher.combine(self.index.hashValue)
        hasher.combine(self.noResultCount.hashValue)
        hasher.combine(self.purchaseCount.hashValue)
        hasher.combine(self.purchaseRate?.hashValue)
        hasher.combine(self.searchCount.hashValue)
        hasher.combine(self.trackedSearchCount?.hashValue)
        hasher.combine(self.trafficPercentage.hashValue)
        hasher.combine(self.userCount.hashValue)
        hasher.combine(self.trackedUserCount.hashValue)
    }
}
