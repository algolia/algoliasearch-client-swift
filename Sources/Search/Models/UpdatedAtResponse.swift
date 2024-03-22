// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import Core
#endif

/// Response, taskID, and update timestamp.
public struct UpdatedAtResponse: Codable, JSONEncodable {
    /// Unique identifier of a task.  A successful API response means that a task was added to a queue. It might not run
    /// immediately. You can check the task's progress with the [`task` operation](#tag/Indices/operation/getTask) and
    /// this `taskID`.
    public var taskID: Int64
    /// Timestamp of the last update in [ISO 8601](https://wikipedia.org/wiki/ISO_8601) format.
    public var updatedAt: String

    public init(taskID: Int64, updatedAt: String) {
        self.taskID = taskID
        self.updatedAt = updatedAt
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case taskID
        case updatedAt
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.taskID, forKey: .taskID)
        try container.encode(self.updatedAt, forKey: .updatedAt)
    }
}
