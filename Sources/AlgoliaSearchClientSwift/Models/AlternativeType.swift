//
//  AlternativeType.swift
//  
//
//  Created by Vladislav Fitc on 23/03/2020.
//
// swiftlint:disable cyclomatic_complexity

import Foundation

public enum AlternativeType: Codable {

  /**
   Literal word from the query
   */
  case original

  /**
   Original keywords that should not appear in the results because it had a “minus” sign at the beginning and
   Query.advancedSyntax enabled.
   */
  case excluded

  /**
   Original keywords that was declared in Query.optionalWords.
   */
  case optional

  /**
   Original keywords that was discarded by Query.removeStopWords.
   */
  case stopWord

  /**
   Alternative that mostly looks like another original keyword. “Mostly looks like” is defined by the
   Damerau-Levenshtein distance between the two words, which counts 1 typo as any insertion, deletion, substitution,
   or transposition of a single character. The field typos contains this number.
   Because it would make no sense to display every combination of typos possible, the response only contains typos
   that were found in the documents.
   */
  case typo

  /**
   Alternative that tries to split every original keyword into 2 valid sub-keywords.
   As for typo, only sub-keywords that were found in the documents may return a split.
   There is always 0 or 1 split per original keyword.
   */
  case split

  /**
   Alternative that tries to build bigrams out of every adjacent pair of keywords (up to the 5th keyword),
   and to build an n-gram out of all the words of the query (if it contains at least 3 words).
   */
  case concat

  /**
   Any of the following kinds of alternatives: one-way synonym, two-way synonym, n-way synonym.
   */
  case synonym

  /**
   Any of the following kinds of alternatives: one-way alternative correction, two-way alternative correction,
   n-way alternative correction. The difference between a synonym and an alternative correction can also be seen
   in the field typos, which will always be 0 in the case of a synonym and 1 or 2 in the case of an alternative
   correction.
   */
  case alternativeCorrection

  /**
   Any declension of the original keywords, including singular and plural, case
   (nominative, accusative, genitive etc.), gender, and others depending on the language.
   Every possible combination is returned, regardless of what the documents contain.
   */
  case plural

  /**
   Word made of several consecutive original query words.
   It is like a concatenation,but based on a decompounding dictionary.
   */
  case compound

  case other(String)

}

extension AlternativeType: RawRepresentable {

  public var rawValue: String {
    switch self {
    case .alternativeCorrection: return "alternativeCorrection"
    case .compound: return "compound"
    case .concat: return "concat"
    case .excluded: return "excluded"
    case .optional: return "optional"
    case .original: return "original"
    case .plural: return "plural"
    case .split: return "split"
    case .stopWord: return "stopWord"
    case .synonym: return "synonym"
    case .typo: return "typo"
    case .other(let value): return value
    }
  }

  public init(rawValue: String) {
    switch rawValue {
    case AlternativeType.alternativeCorrection.rawValue: self = .alternativeCorrection
    case AlternativeType.compound.rawValue: self = .compound
    case AlternativeType.concat.rawValue: self = .concat
    case AlternativeType.excluded.rawValue: self = .excluded
    case AlternativeType.optional.rawValue: self = .optional
    case AlternativeType.original.rawValue: self = .original
    case AlternativeType.plural.rawValue: self = .plural
    case AlternativeType.split.rawValue: self = .split
    case AlternativeType.stopWord.rawValue: self = .stopWord
    case AlternativeType.synonym.rawValue: self = .synonym
    case AlternativeType.typo.rawValue: self = .typo
    default: self = .other(rawValue)
    }
  }

}
