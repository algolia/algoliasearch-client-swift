//
//  Rule+Consequence.swift
//
//
//  Created by Vladislav Fitc on 04/05/2020.
//

import Foundation

extension Rule {
  public struct Consequence {
    /// Names of facets to which automatic filtering must be applied; they must match the facet name of a facet value
    /// placeholder in the query pattern.
    /// - Example: facetName1, facetName2. You can specify a score: facetName1<score=5>, facetName2<score=1>.
    public var automaticFacetFilters: [AutomaticFacetFilters]?

    /// Same as automaticFacetFilters, but the engine treats the filters as optional.
    /// Behaves like Query.optionalFilters.
    public var automaticOptionalFacetFilters: [AutomaticFacetFilters]?

    /// Query.query is ignored if queryTextAlteration is set
    public var query: Query?

    /// When providing a Query.query, You can't do both this and edits at the same time.
    public var queryTextAlteration: QueryTextAlteration?

    /// Objects to promote as hits.
    public var promote: [Promotion]?

    /// Whether promoted results should match the filters of the current search.
    public var filterPromotes: Bool?

    /// Objects to hide from hits.
    public var hide: [ObjectID]?

    /// Content defining how the search interface should be rendered.
    /// A default value for this can be set via settings.
    public var renderingContent: RenderingContent?

    /// Custom JSON object that will be appended to the SearchResponse.userData.
    /// This object is not interpreted by the API. It is limited to 1kB of minified JSON.
    public var userData: JSON?

    public init() {}
  }
}

extension Rule.Consequence: Builder {}

extension Rule.Consequence {
  public enum QueryTextAlteration: Codable {
    /// Replacement for the entire query string.
    case replacement(String)

    /// Describes incremental edits to be made to the query string.
    case edits([Rule.Edit])

    public init(from decoder: Decoder) throws {
      if let removeWrapper = try? FieldWrapper<RemoveKey, [String]>(from: decoder) {
        let edits: [Rule.Edit] = removeWrapper.wrapped.map { .remove($0) }
        self = .edits(edits)
      } else if let editsWrapper = try? EditsWrapper(from: decoder) {
        self = .edits(editsWrapper.wrapped)
      } else {
        let container = try decoder.singleValueContainer()
        let rawReplacement = try container.decode(String.self)
        self = .replacement(rawReplacement)
      }
    }

    public func encode(to encoder: Encoder) throws {
      switch self {
      case .replacement(let queryString):
        var container = encoder.singleValueContainer()
        try container.encode(queryString)
      case .edits(let edits):
        let editsWrapper = EditsWrapper(edits)
        try editsWrapper.encode(to: encoder)
      }
    }
  }
}

extension Rule.Consequence {
  struct Params: Builder, Codable {
    var query: Query?
    var queryTextAlteration: QueryTextAlteration?
    var automaticFacetFilters: [Rule.AutomaticFacetFilters]?
    var automaticOptionalFacetFilters: [Rule.AutomaticFacetFilters]?
    var renderingContent: RenderingContent?

    enum CodingKeys: String, CodingKey {
      case query
      case automaticFacetFilters
      case automaticOptionalFacetFilters
      case renderingContent
    }

    public init() {}

    public init(from decoder: Decoder) throws {
      query = try Query(from: decoder)
      let container = try decoder.container(keyedBy: CodingKeys.self)
      queryTextAlteration = try container.decodeIfPresent(forKey: .query)
      automaticFacetFilters = try container.decodeIfPresent(forKey: .automaticFacetFilters)
      automaticOptionalFacetFilters = try container.decodeIfPresent(
        forKey: .automaticOptionalFacetFilters)
      renderingContent = try container.decodeIfPresent(forKey: .renderingContent)
    }

    public func encode(to encoder: Encoder) throws {
      try query?.encode(to: encoder)
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encodeIfPresent(queryTextAlteration, forKey: .query)
      try container.encodeIfPresent(automaticFacetFilters, forKey: .automaticFacetFilters)
      try container.encodeIfPresent(
        automaticOptionalFacetFilters, forKey: .automaticOptionalFacetFilters)
      try container.encodeIfPresent(renderingContent, forKey: .renderingContent)
    }
  }
}

extension Rule.Consequence: Codable {
  enum CodingKeys: String, CodingKey {
    case promote
    case filterPromotes
    case hide
    case userData
  }

  public init(from decoder: Decoder) throws {
    let params = try ParamsWrapper<Params>(from: decoder)
    query = params.wrapped.query
    queryTextAlteration = params.wrapped.queryTextAlteration
    automaticFacetFilters = params.wrapped.automaticFacetFilters
    automaticOptionalFacetFilters = params.wrapped.automaticOptionalFacetFilters
    renderingContent = params.wrapped.renderingContent
    let container = try decoder.container(keyedBy: CodingKeys.self)
    promote = try container.decodeIfPresent(forKey: .promote)
    filterPromotes = try container.decodeIfPresent(forKey: .filterPromotes)
    let hideWrappers = try container.decodeIfPresent([ObjectIDWrapper].self, forKey: .hide)
    hide = hideWrappers.flatMap { $0.map(\.wrapped) }
    userData = try container.decodeIfPresent(forKey: .userData)
  }

  public func encode(to encoder: Encoder) throws {
    let params = Params()
      .set(\.query, to: query)
      .set(\.queryTextAlteration, to: queryTextAlteration)
      .set(\.automaticFacetFilters, to: automaticFacetFilters)
      .set(\.automaticOptionalFacetFilters, to: automaticOptionalFacetFilters)
      .set(\.renderingContent, to: renderingContent)
    try ParamsWrapper<Params>(params).encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(promote, forKey: .promote)
    try container.encodeIfPresent(filterPromotes, forKey: .filterPromotes)
    let hideWrappers = hide.flatMap { $0.map(ObjectIDWrapper.init) }
    try container.encodeIfPresent(hideWrappers, forKey: .hide)
    try container.encodeIfPresent(userData, forKey: .userData)
  }
}
