// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import AlgoliaCore
#endif

/// Synonym object.
public struct SynonymHit: Codable, JSONEncodable {
    /// Unique identifier of a synonym object.
    public var objectID: String
    public var type: SynonymType
    /// Words or phrases considered equivalent.
    public var synonyms: [String]?
    /// Word or phrase to appear in query strings (for [`onewaysynonym`s](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/adding-synonyms/in-depth/one-way-synonyms/)).
    public var input: String?
    /// Word or phrase to appear in query strings (for [`altcorrection1` and `altcorrection2`](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/adding-synonyms/in-depth/synonyms-alternative-corrections/)).
    public var word: String?
    /// Words to be matched in records.
    public var corrections: [String]?
    /// [Placeholder token](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/adding-synonyms/in-depth/synonyms-placeholders/)
    /// to be put inside records.
    public var placeholder: String?
    /// Query words that will match the [placeholder token](https://www.algolia.com/doc/guides/managing-results/optimize-search-results/adding-synonyms/in-depth/synonyms-placeholders/).
    public var replacements: [String]?

    public init(
        objectID: String,
        type: SynonymType,
        synonyms: [String]? = nil,
        input: String? = nil,
        word: String? = nil,
        corrections: [String]? = nil,
        placeholder: String? = nil,
        replacements: [String]? = nil
    ) {
        self.objectID = objectID
        self.type = type
        self.synonyms = synonyms
        self.input = input
        self.word = word
        self.corrections = corrections
        self.placeholder = placeholder
        self.replacements = replacements
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case objectID
        case type
        case synonyms
        case input
        case word
        case corrections
        case placeholder
        case replacements
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.objectID, forKey: .objectID)
        try container.encode(self.type, forKey: .type)
        try container.encodeIfPresent(self.synonyms, forKey: .synonyms)
        try container.encodeIfPresent(self.input, forKey: .input)
        try container.encodeIfPresent(self.word, forKey: .word)
        try container.encodeIfPresent(self.corrections, forKey: .corrections)
        try container.encodeIfPresent(self.placeholder, forKey: .placeholder)
        try container.encodeIfPresent(self.replacements, forKey: .replacements)
    }
}

extension SynonymHit: Equatable {
    public static func ==(lhs: SynonymHit, rhs: SynonymHit) -> Bool {
        lhs.objectID == rhs.objectID &&
            lhs.type == rhs.type &&
            lhs.synonyms == rhs.synonyms &&
            lhs.input == rhs.input &&
            lhs.word == rhs.word &&
            lhs.corrections == rhs.corrections &&
            lhs.placeholder == rhs.placeholder &&
            lhs.replacements == rhs.replacements
    }
}

extension SynonymHit: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.objectID.hashValue)
        hasher.combine(self.type.hashValue)
        hasher.combine(self.synonyms?.hashValue)
        hasher.combine(self.input?.hashValue)
        hasher.combine(self.word?.hashValue)
        hasher.combine(self.corrections?.hashValue)
        hasher.combine(self.placeholder?.hashValue)
        hasher.combine(self.replacements?.hashValue)
    }
}
