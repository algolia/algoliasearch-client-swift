//
//  File.swift
//  
//
//  Created by Vladislav Fitc on 13.03.2020.
//

import Foundation

public struct TaggedString: Hashable {
  
  public let input: String
  public let output: String
  public let taggedRanges: [Range<String.Index>]
  public let untaggedRanges: [Range<String.Index>]
  
  public init(string: String, preTag: String, postTag: String, options: String.CompareOptions = []) {
    // This string reconstruction is here to avoid a potential problems due to string encoding
    // Check unit test TaggedStringTests -> testWithDecodedString
    let string = String(string.indices.map { string [$0] })
    self.input = string
    let (output, rangesToHighlight) = TaggedString.computeRanges(for: string, preTag: preTag, postTag: postTag, options: options)
    self.output = output
    self.taggedRanges = rangesToHighlight
    self.untaggedRanges = TaggedString.computeInvertedRanges(for: output, with: rangesToHighlight)
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
