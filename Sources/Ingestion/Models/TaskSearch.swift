// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

public struct TaskSearch: Codable, JSONEncodable {
    public var taskIDs: [String]

    public init(taskIDs: [String]) {
        self.taskIDs = taskIDs
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case taskIDs
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.taskIDs, forKey: .taskIDs)
    }
}

extension TaskSearch: Equatable {
    public static func ==(lhs: TaskSearch, rhs: TaskSearch) -> Bool {
        lhs.taskIDs == rhs.taskIDs
    }
}

extension TaskSearch: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.taskIDs.hashValue)
    }
}
