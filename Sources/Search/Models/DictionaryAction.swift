// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

/// Actions to perform.
public enum DictionaryAction: String, Codable, CaseIterable {
    case addEntry
    case deleteEntry
}

extension DictionaryAction: Hashable {}
