// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

/// Operation to perform on the index.
public enum OperationType: String, Codable, CaseIterable {
    case move
    case copy
}

extension OperationType: Hashable {}
