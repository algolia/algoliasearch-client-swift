// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Core
import Foundation
#if canImport(AnyCodable)
    import AnyCodable
#endif

/** Synonym type. */
public enum SynonymType: String, Codable, CaseIterable {
    case synonym
    case onewaysynonym
    case altcorrection1
    case altcorrection2
    case placeholder
}