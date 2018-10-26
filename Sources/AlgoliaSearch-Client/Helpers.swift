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

// MARK: - URL encoding

/// Character set allowed as a component of the path portion of a URL.
/// Basically it's just the default `NSCharacterSet.URLPathAllowedCharacterSet()` minus the slash character.
///
internal let URLPathComponentAllowedCharacterSet: CharacterSet = {
  var characterSet = CharacterSet()
  characterSet.formUnion(CharacterSet.urlPathAllowed)
  characterSet.remove(charactersIn: "/")
  return characterSet
}()

// Allowed characters taken from [RFC 3986](https://tools.ietf.org/html/rfc3986) (cf. §2 "Characters"):
// - unreserved  = ALPHA / DIGIT / "-" / "." / "_" / "~"
// - gen-delims  = ":" / "/" / "?" / "#" / "[" / "]" / "@"
// - sub-delims  = "!" / "$" / "&" / "'" / "(" / ")" / "*" / "+" / "," / ";" / "="
//
// ... with these further restrictions:
// - ampersand ('&') and equal sign ('=') removed because they are used as delimiters for the parameters;
// - question mark ('?') and hash ('#') removed because they mark the beginning and the end of the query string.
// - plus ('+') is removed because it is interpreted as a space by Algolia's servers.
//
let URLQueryParamAllowedCharacterSet = CharacterSet(charactersIn:
  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~:/[]@!$'()*,;")

extension String {
  /// Return an URL-encoded version of the string suitable for use as a component of the path portion of a URL.
  func urlEncodedPathComponent() -> String {
    return addingPercentEncoding(withAllowedCharacters: URLPathComponentAllowedCharacterSet)!
  }

  /// Return an URL-encoded version of the string suitable for use as a query parameter key or value.
  func urlEncodedQueryParam() -> String {
    return addingPercentEncoding(withAllowedCharacters: URLQueryParamAllowedCharacterSet)!
  }
}

// MARK: - Memory debugging

// NOTE: Those helpers are not used in the code, but let's keep them because they can be handy when debugging.

/// Log the initialization of an object.
func logInit(_ object: AnyObject) {
  print("<INIT> \(Unmanaged.passUnretained(object).toOpaque()) (\(type(of: object))) \(String(describing: object))")
}

/// Log the termination ("de-initialization" in Swift terms) of an object.
func logTerm(_ object: AnyObject) {
  print("<TERM> \(Unmanaged.passUnretained(object).toOpaque()) (\(type(of: object))) \(String(describing: object))")
}

// MARK: - Collection shuffling

// Taken from <http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift>.

extension Collection {
  /// Return a copy of `self` with its elements shuffled.
  func shuffle() -> [Iterator.Element] {
    var list = Array(self)
    list.shuffleInPlace()
    return list
  }
}

extension MutableCollection where Index == Int {
  /// Shuffle the elements of `self` in-place.
  mutating func shuffleInPlace() {
    // Empty and single-element collections don't shuffle.
    if count < 2 { return }

    for i in 0 ..< endIndex {
      let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
      guard i != j else { continue }
      swapAt(i, j)
    }
  }
}

// MARK: - Dates

let iso8601DateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.calendar = Calendar(identifier: .iso8601)
  formatter.locale = Locale(identifier: "en_US_POSIX")
  formatter.timeZone = TimeZone(secondsFromGMT: 0)
  formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" // "2000-12-31T23:59:59.666Z"
  return formatter
}()

extension Date {
  var iso8601: String {
    return iso8601DateFormatter.string(from: self)
  }
}

// MARK: - Thread synchronization

extension NSObject {
  /// Equivalent of Objective-C's `@synchronized` statement.
  /// Actually leverages the same Objective-C runtime feature (this is why it's only available on `NSObject`).
  ///
  /// - paremeter block: Block to be executed serially on the object.
  ///
  func synchronized<T>(_ block: () -> T) -> T {
    objc_sync_enter(self)
    defer {
      objc_sync_exit(self)
    }
    return block()
  }
}

// MARK: - Miscellaneous

/// The operating system's name.
///
/// - returns: The operating system's name, or nil if it could not be determined.
///
internal var osName: String? {
  #if os(iOS)
    return "iOS"
  #elseif os(OSX)
    return "macOS"
  #elseif os(tvOS)
    return "tvOS"
  #elseif os(watchOS)
    return "watchOS"
  #else
    return nil
  #endif
}
