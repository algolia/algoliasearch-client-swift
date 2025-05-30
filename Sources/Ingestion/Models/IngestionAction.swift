// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import Core
#endif

/// Type of indexing operation.
public enum IngestionAction: String, Codable, CaseIterable {
    case addObject
    case updateObject
    case partialUpdateObject
    case partialUpdateObjectNoCreate
}

extension IngestionAction: Hashable {}
