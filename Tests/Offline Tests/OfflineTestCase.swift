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
import InstantSearchClientOffline
import XCTest

class OfflineTestCase: XCTestCase {
  var client: OfflineClient!

  let expectationTimeout: TimeInterval = 5

  override func setUp() {
    super.setUp()

    // Create client.
    let appID = Bundle(for: type(of: self)).object(forInfoDictionaryKey: "ALGOLIA_APPLICATION_ID") as? String ?? ""
    let apiKey = Bundle(for: type(of: self)).object(forInfoDictionaryKey: "ALGOLIA_API_KEY") as? String ?? ""
    client = OfflineClient(appID: appID, apiKey: apiKey)
    client.enableOfflineMode(licenseKey: "AioCAQH/uLqiBf+k1Z4FlwcYQWxnb2xpYSBEZXZlbG9wbWVudCBUZWFtASowLgIVALmd8rEYFPy+FzhmQskzabybdGqWAhUAuXwHnlD1Sb9v/FdPfJ1FmQ5Iid0=")

    // Clean-up data from potential previous runs.
    if FileManager.default.fileExists(atPath: client.rootDataDir) {
      try! FileManager.default.removeItem(atPath: client.rootDataDir)
    }
  }

  override func tearDown() {
    super.tearDown()
  }

  let settings: [String: Any] = [
    "searchableAttributes": ["name", "kind", "series"],
    "attributesForFaceting": ["searchable(series)"],
  ]

  let objects: [String: [String: Any]] = [
    "snoopy": [
      "objectID": "1",
      "name": "Snoopy",
      "kind": "dog",
      "born": 1967,
      "series": "Peanuts",
    ],
    "woodstock": [
      "objectID": "2",
      "name": "Woodstock",
      "kind": "bird",
      "born": 1970,
      "series": "Peanuts",
    ],
  ]
}
