// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Core
import Foundation
#if canImport(AnyCodable)
    import AnyCodable
#endif

// MARK: - DockerSourceStreams

public struct DockerSourceStreams: Codable, JSONEncodable, Hashable {
    // MARK: Lifecycle

    public init(streams: [AnyCodable]) {
        self.streams = streams
    }

    // MARK: Public

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case streams
    }

    public var streams: [AnyCodable]

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.streams, forKey: .streams)
    }
}
