// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

/// Trigger information for manually-triggered tasks.
public struct OnDemandTriggerInput: Codable, JSONEncodable {
    public var type: OnDemandTriggerType

    public init(type: OnDemandTriggerType) {
        self.type = type
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case type
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.type, forKey: .type)
    }
}

extension OnDemandTriggerInput: Equatable {
    public static func ==(lhs: OnDemandTriggerInput, rhs: OnDemandTriggerInput) -> Bool {
        lhs.type == rhs.type
    }
}

extension OnDemandTriggerInput: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.type.hashValue)
    }
}
