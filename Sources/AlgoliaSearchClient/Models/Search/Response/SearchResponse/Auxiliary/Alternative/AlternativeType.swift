//
//  AlternativeType.swift
//  
//
//  Created by Vladislav Fitc on 23/03/2020.
//

import Foundation

public struct AlternativeType: StringOption & ProvidingCustomOption {

  public let rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }

  /**
   Literal word from the query
   */
  public static var original: Self { .init(rawValue: #function) }

  /**
   Original keywords that should not appear in the results because it had a “minus” sign at the beginning and
   Query.advancedSyntax enabled.
   */
  public static var excluded: Self { .init(rawValue: #function) }

  /**
   Original keywords that was declared in Query.optionalWords.
   */
  public static var optional: Self { .init(rawValue: #function) }

  /**
   Original keywords that was discarded by Query.removeStopWords.
   */
  public static var stopWord: Self { .init(rawValue: #function) }

  /**
   Alternative that mostly looks like another original keyword. “Mostly looks like” is defined by the
   Damerau-Levenshtein distance between the two words, which counts 1 typo as any insertion, deletion, substitution,
   or transposition of a single character. The field typos contains this number.
   Because it would make no sense to display every combination of typos possible, the response only contains typos
   that were found in the documents.
   */
  public static var typo: Self { .init(rawValue: #function) }

  /**
   Alternative that tries to split every original keyword into 2 valid sub-keywords.
   As for typo, only sub-keywords that were found in the documents may return a split.
   There is always 0 or 1 split per original keyword.
   */
  public static var split: Self { .init(rawValue: #function) }

  /**
   Alternative that tries to build bigrams out of every adjacent pair of keywords (up to the 5th keyword),
   and to build an n-gram out of all the words of the query (if it contains at least 3 words).
   */
  public static var concat: Self { .init(rawValue: #function) }

  /**
   Any of the following kinds of alternatives: one-way synonym, two-way synonym, n-way synonym.
   */
  public static var synonym: Self { .init(rawValue: #function) }

  /**
   Any of the following kinds of alternatives: one-way alternative correction, two-way alternative correction,
   n-way alternative correction. The difference between a synonym and an alternative correction can also be seen
   in the field typos, which will always be 0 in the case of a synonym and 1 or 2 in the case of an alternative
   correction.
   */
  public static var alternativeCorrection: Self { .init(rawValue: #function) }

  /**
   Any declension of the original keywords, including singular and plural, case
   (nominative, accusative, genitive etc.), gender, and others depending on the language.
   Every possible combination is returned, regardless of what the documents contain.
   */
  public static var plural: Self { .init(rawValue: #function) }

  /**
   Word made of several consecutive original query words.
   It is like a concatenation,but based on a decompounding dictionary.
   */
  public static var compound: Self { .init(rawValue: #function) }

}
