//
//  Copyright (c) 2015 Algolia
//  http://www.algolia.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

func safeIndexName(_ name: String) -> String {
  var targetName = Bundle.main.object(forInfoDictionaryKey: "BUILD_TARGET_NAME") as? String ?? ""
  targetName = targetName.replacingOccurrences(of: " ", with: "-")

  if let travisBuild = ProcessInfo.processInfo.environment["TRAVIS_JOB_NUMBER"] {
    return "\(name)_travis_\(travisBuild)"
  } else if let bitriseBuild = Bundle.main.object(forInfoDictionaryKey: "BITRISE_BUILD_NUMBER") as? String {
    return "\(name)_bitrise_\(bitriseBuild)_\(targetName)"
  } else {
    return name
  }
}

func average(values: [Double]) -> Double {
  return values.reduce(0, +) / Double(values.count)
}

/// Generate a new host name in the `algolia.biz` domain.
/// The DNS lookup for any host in the `algolia.biz` domain will time-out.
/// Generating a new host name every time avoids any system-level or network-level caching side effect.
///
func uniqueAlgoliaBizHost() -> String {
  return "swift-\(UInt32(NSDate().timeIntervalSince1970)).algolia.biz"
}
