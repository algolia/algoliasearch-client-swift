// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

public struct ObjectData: Codable, JSONEncodable {
    public var price: Price?
    /// Quantity of a product that has been purchased or added to the cart. The total purchase value is the sum of
    /// `quantity` multiplied with the `price` for each purchased item.
    public var quantity: Int?
    public var discount: Discount?

    public init(price: Price? = nil, quantity: Int? = nil, discount: Discount? = nil) {
        self.price = price
        self.quantity = quantity
        self.discount = discount
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case price
        case quantity
        case discount
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.price, forKey: .price)
        try container.encodeIfPresent(self.quantity, forKey: .quantity)
        try container.encodeIfPresent(self.discount, forKey: .discount)
    }
}

extension ObjectData: Equatable {
    public static func ==(lhs: ObjectData, rhs: ObjectData) -> Bool {
        lhs.price == rhs.price &&
            lhs.quantity == rhs.quantity &&
            lhs.discount == rhs.discount
    }
}

extension ObjectData: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.price?.hashValue)
        hasher.combine(self.quantity?.hashValue)
        hasher.combine(self.discount?.hashValue)
    }
}
