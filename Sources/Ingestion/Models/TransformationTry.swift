// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import Core
#endif

public struct TransformationTry: Codable, JSONEncodable {
    /// The source code of the transformation.
    public var code: String
    /// The record to apply the given code to.
    public var sampleRecord: AnyCodable

    public init(code: String, sampleRecord: AnyCodable) {
        self.code = code
        self.sampleRecord = sampleRecord
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case code
        case sampleRecord
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.code, forKey: .code)
        try container.encode(self.sampleRecord, forKey: .sampleRecord)
    }
}

extension TransformationTry: Equatable {
    public static func ==(lhs: TransformationTry, rhs: TransformationTry) -> Bool {
        lhs.code == rhs.code &&
            lhs.sampleRecord == rhs.sampleRecord
    }
}

extension TransformationTry: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.code.hashValue)
        hasher.combine(self.sampleRecord.hashValue)
    }
}