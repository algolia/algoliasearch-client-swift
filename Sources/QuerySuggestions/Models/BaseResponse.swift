// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Core
import Foundation
#if canImport(AnyCodable)
    import AnyCodable
#endif

// MARK: - BaseResponse

public struct BaseResponse: Codable, JSONEncodable, Hashable {
    // MARK: Lifecycle

    public init(status: Int? = nil, message: String? = nil) {
        self.status = status
        self.message = message
    }

    // MARK: Public

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case status
        case message
    }

    /// HTTP status code.
    public var status: Int?
    /// Details about the response, such as error messages.
    public var message: String?

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.status, forKey: .status)
        try container.encodeIfPresent(self.message, forKey: .message)
    }
}
