// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

/// Character that characterizes how the filter is applied.  For example, for a facet filter `facet:value`, `:` is the
/// operator. For a numeric filter `count>50`, `>` is the operator.
public enum Operator: String, Codable, CaseIterable {
    case colon = ":"
    case lessThan = "<"
    case lessThanOrEqualTo = "<="
    case equal = "="
    case notEqual = "!="
    case greaterThan = ">"
    case greaterThanOrEqualTo = ">="
}

extension Operator: Hashable {}
