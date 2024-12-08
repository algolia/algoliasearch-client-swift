// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

public struct IncidentsResponse: Codable, JSONEncodable {
    public var incidents: [String: [IncidentEntry]]?

    public init(incidents: [String: [IncidentEntry]]? = nil) {
        self.incidents = incidents
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case incidents
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.incidents, forKey: .incidents)
    }
}

extension IncidentsResponse: Equatable {
    public static func ==(lhs: IncidentsResponse, rhs: IncidentsResponse) -> Bool {
        lhs.incidents == rhs.incidents
    }
}

extension IncidentsResponse: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.incidents?.hashValue)
    }
}
