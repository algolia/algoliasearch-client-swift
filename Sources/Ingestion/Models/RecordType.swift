// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

/// Record type for ecommerce sources.
public enum RecordType: String, Codable, CaseIterable {
    case product
    case variant
}

extension RecordType: Hashable {}
