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
  
  public mutating func taggedSubstrings() -> [Substring] {
    return taggedRanges.map { output[$0] }
  }
  
  public mutating func untaggedSubstrings() -> [Substring] {
    return untaggedRanges.map { output[$0] }
  }

  private static func computeRanges(for string: String, preTag: String, postTag: String, options: String.CompareOptions) -> (output: String, ranges: [Range<String.Index>]) {
    var output = string
    var preStack: [R] = []
    var rangesToHighlight = [R]()
    
    typealias R = Range<String.Index>

    enum Tag {
      case pre(R), post(R)
    }
    
    func nextTag(in string: String) -> Tag? {
      switch (string.range(of: preTag, options: options), string.range(of: postTag, options: options)) {
      case (.some(let pre), .some(let post)) where pre.lowerBound < post.lowerBound:
        return .pre(pre)
      case (.some, .some(let post)):
        return .post(post)
      case (.some(let pre), .none):
        return .pre(pre)
      case (.none, .some(let post)):
        return .post(post)
      case (.none, .none):
        return nil
      }
    }
        
    while let nextTag = nextTag(in: output) {
      switch nextTag {
      case .pre(let preRange):
        preStack.append(preRange)
        output.removeSubrange(preRange)
      case .post(let postRange):
        if let lastPre = preStack.last {
          preStack.removeLast()
          rangesToHighlight.append(.init(uncheckedBounds: (lastPre.lowerBound, postRange.lowerBound)))
        }
        output.removeSubrange(postRange)
      }
    }
        
    return (output, mergeOverlapping(rangesToHighlight))
  }
  
  static func mergeOverlapping<T: Comparable>(_ input: [Range<T>]) -> [Range<T>] {
    var output: [Range<T>] = []
    let sortedRanges = input.sorted(by: { $0.lowerBound < $1.lowerBound })
    guard let head = sortedRanges.first else { return output }
    let tail = sortedRanges.suffix(from: sortedRanges.index(after: sortedRanges.startIndex))
    var (lower, upper) = (head.lowerBound, head.upperBound)
    for range in tail {
      if range.lowerBound <= upper {
        if range.upperBound > upper {
          upper = range.upperBound
        } else {
          continue
        }
      } else {
        output.append(.init(uncheckedBounds: (lower: lower, upper: upper)))
        (lower, upper) = (range.lowerBound, range.upperBound)
      }
    }
    output.append(.init(uncheckedBounds: (lower: lower, upper: upper)))
    return output
  }

  private static func computeInvertedRanges(for string: String, with ranges: [Range<String.Index>]) -> [Range<String.Index>] {
    
    if ranges.isEmpty {
      return ([string.startIndex..<string.endIndex])
    }
    
    var lowerBound = string.startIndex
    
    var invertedRanges: [Range<String.Index>] = []

    for range in ranges where range.lowerBound >= lowerBound {
      if lowerBound != range.lowerBound {
        let invertedRange = lowerBound..<range.lowerBound
        invertedRanges.append(invertedRange)
      }
      lowerBound = range.upperBound
    }

    if lowerBound != string.endIndex, lowerBound != string.startIndex {
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
