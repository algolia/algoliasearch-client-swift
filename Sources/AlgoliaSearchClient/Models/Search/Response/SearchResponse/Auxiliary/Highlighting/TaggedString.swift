//
//  TaggedString.swift
//  
//
//  Created by Vladislav Fitc on 13.03.2020.
//

import Foundation

public struct TaggedString {

  public let input: String
  public let preTag: String
  public let postTag: String
  public let options: String.CompareOptions
  
  private lazy var storage: (String, [Range<String.Index>]) = TaggedString.computeRanges(for: input, preTag: preTag, postTag: postTag, options: options)
  
  public private(set) lazy var output: String = { storage.0 }()
  public private(set) lazy var taggedRanges: [Range<String.Index>] = { storage.1 }()
  public private(set) lazy var untaggedRanges: [Range<String.Index>] = TaggedString.computeInvertedRanges(for: output, with: taggedRanges)

  public init(string: String, preTag: String, postTag: String, options: String.CompareOptions = []) {
    // This string reconstruction is here to avoid a potential problems due to string encoding
    // Check unit test TaggedStringTests -> testWithDecodedString
    let string = String(string.indices.map { string [$0] })
    self.input = string
    self.preTag = preTag
    self.postTag = postTag
    self.options = options
  }

  private static func computeRanges(for string: String, preTag: String, postTag: String, options: String.CompareOptions) -> (output: String, ranges: [Range<String.Index>]) {

    var newText = string
    var rangesToHighlight = [Range<String.Index>]()

    while let matchBegin = newText.range(of: preTag, options: options) {
      newText.removeSubrange(matchBegin)
      let tailRange = matchBegin.lowerBound..<newText.endIndex
      guard let matchEnd = newText.range(of: postTag, options: options, range: tailRange) else { continue }
      newText.removeSubrange(matchEnd)
      rangesToHighlight.append(.init(uncheckedBounds: (matchBegin.lowerBound, matchEnd.lowerBound)))
    }

    return (newText, rangesToHighlight)

  }

  private static func computeInvertedRanges(for string: String, with ranges: [Range<String.Index>]) -> [Range<String.Index>] {

    var lowerBound = string.startIndex
    
    var invertedRanges: [Range<String.Index>] = []

    for range in ranges {
      if lowerBound != range.lowerBound {
        let invertedRange = lowerBound..<range.lowerBound
        invertedRanges.append(invertedRange)
      }
      lowerBound = range.upperBound
    }

    if lowerBound != string.endIndex {
      invertedRanges.append(lowerBound..<string.endIndex)
    }

    return invertedRanges

  }

}

extension TaggedString: Hashable {
  
  public func hash(into hasher: inout Hasher) {
    input.hash(into: &hasher)
    preTag.hash(into: &hasher)
    postTag.hash(into: &hasher)
  }
    
}
