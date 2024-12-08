// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

/// Response, taskID, and deletion timestamp.
public struct RecommendDeletedAtResponse: Codable, JSONEncodable {
    /// Unique identifier of a task.  A successful API response means that a task was added to a queue. It might not run
    /// immediately. You can check the task's progress with the [`task` operation](#tag/Indices/operation/getTask) and
    /// this `taskID`.
    public var taskID: Int64
    /// Date and time when the object was deleted, in RFC 3339 format.
    public var deletedAt: String

    public init(taskID: Int64, deletedAt: String) {
        self.taskID = taskID
        self.deletedAt = deletedAt
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case taskID
        case deletedAt
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.taskID, forKey: .taskID)
        try container.encode(self.deletedAt, forKey: .deletedAt)
    }
}

extension RecommendDeletedAtResponse: Equatable {
    public static func ==(lhs: RecommendDeletedAtResponse, rhs: RecommendDeletedAtResponse) -> Bool {
        lhs.taskID == rhs.taskID &&
            lhs.deletedAt == rhs.deletedAt
    }
}

extension RecommendDeletedAtResponse: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.taskID.hashValue)
        hasher.combine(self.deletedAt.hashValue)
    }
}
