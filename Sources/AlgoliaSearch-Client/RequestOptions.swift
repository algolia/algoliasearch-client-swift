//
//  Copyright (c) 2016 Algolia
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

/// Per-request options.
/// This class allows specifying options at the request level, overriding default options at the `Client` level.
///
/// + Note: These are reserved for advanced use cases. In most situations, they shouldn't be needed.
///
@objc
public class RequestOptions: NSObject, NSCopying {
  // MARK: - Low-level storage

  /// HTTP headers, as untyped values.
  @objc public var headers: [String: String] = [:]

  /// URL parameters, as untyped values.
  /// These will go into the query string part of the URL (after the question mark).
  @objc public var urlParameters: [String: String] = [:]

  // MARK: - Miscellaneous

  @objc open override var description: String { return "\(String(describing: type(of: self))){\(headers)}" }

  // MARK: - Initialization

  /// Construct request options.
  ///
  /// - param headers: HTTP headers (default: empty).
  /// - param urlParameters: URL parameters (default: empty).
  ///
  @objc public init(headers: [String: String] = [:], urlParameters: [String: String] = [:]) {
    self.headers = headers
    self.urlParameters = urlParameters
  }

  // MARK: - NSCopying

  /// Support for `NSCopying`.
  ///
  @objc open func copy(with _: NSZone?) -> Any {
    // NOTE: As per the docs, the zone argument is ignored.
    return RequestOptions(headers: headers)
  }

  // MARK: - Equatable

  open override func isEqual(_ object: Any?) -> Bool {
    guard let rhs = object as? RequestOptions else {
      return false
    }
    return headers == rhs.headers
  }
}
