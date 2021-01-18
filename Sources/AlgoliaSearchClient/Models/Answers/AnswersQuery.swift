//
//  AnswersQuery.swift
//  
//
//  Created by Vladislav Fitc on 19/11/2020.
//

import Foundation

public struct AnswersQuery: SearchParameters, Codable {

  /// The query for which to retrieve results.
  public var query: String
  
  /// The languages in the query.
  ///
  /// Default value: [.english]
  public var queryLanguages: [Language]

  /// Attributes to use for predictions.
  ///
  /// Default value: ["*"]  (all searchable attributes)
  /// - Warning: All your attributesForPrediction must be part of your searchableAttributes.
  public var attributesForPrediction: [Attribute]?

  /// Maximum number of answers to retrieve from the Answers Engine.
  ///
  /// Default value: 10
  ///
  /// Cannot be greater than 1000.
  public var nbHits: Int?

  /// Threshold for the answers’ confidence score: only answers with extracts that score above this threshold are returned.
  ///
  /// Default value: 0.0
  public var threshold: Double?

  /// Not supported by Answers
  public var attributesToSnippet: [Snippet]? {
    get {
      return nil
    }
    // swiftlint:disable:next unused_setter_value
    set {
      assertionFailure("attributesToSnippet is not supported by answers")
    }
  }

  /// Not supported by Answers
  public var hitsPerPage: Int? {
    get {
      return nil
    }
    // swiftlint:disable:next unused_setter_value
    set {
      assertionFailure("hitsPerPage is not supported by answers")
    }
  }

  /// Not supported by Answers
  public var restrictSearchableAttributes: [Attribute]? {
    get {
      return nil
    }
    // swiftlint:disable:next unused_setter_value
    set {
      assertionFailure("restrictSearchableAttributes is not supported by answers")
    }
  }

  internal var params: SearchParametersStorage?

  public init(query: String, queryLanguages: [Language]) {
    self.query = query
    self.queryLanguages = queryLanguages
  }

}

extension AnswersQuery: ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    self.init(query: value, queryLanguages: [.english])
  }

}

extension AnswersQuery: SearchParametersStorageContainer {

  var searchParametersStorage: SearchParametersStorage {
    get {
      return params ?? .init()
    }

    set {
      params = newValue
    }
  }

}

extension AnswersQuery: Builder {}
