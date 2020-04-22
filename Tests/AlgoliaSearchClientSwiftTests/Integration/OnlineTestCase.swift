//
//  OnlineTestCase.swift
//  
//
//  Created by Vladislav Fitc on 05/03/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class OnlineTestCase: XCTestCase {

  var client: Client!
  var index: Index!
  let expectationTimeout: TimeInterval = 100

  /// Abstract base class for online test cases.
  ///
  
  var indexNameSuffix: String? {
    return nil
  }

  override func setUpWithError() throws {

    try super.setUpWithError()

    guard let credentials = TestCredentials.environment else {
      throw Error.missingCredentials
    }
	
    client = Client(appID: credentials.applicationID, apiKey: credentials.apiKey)
    
    let className = String(reflecting: type(of: self)).components(separatedBy: ".").last!
    let functionName = invocation!.selector.description
    let indexNameSuffix = self.indexNameSuffix ?? "\(className).\(functionName)"
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY-MM-DD_HH:mm:ss"
    let dateString = dateFormatter.string(from: .init())
    let indexName = IndexName(stringLiteral: "swift_\(dateString)_\(NSUserName().description)_\(indexNameSuffix)")
    index = client.index(withName: indexName)

    try index.delete()
  }

  override func tearDownWithError() throws {
    try super.tearDownWithError()
    try index.delete()
  }

}

extension OnlineTestCase {
  enum Error: Swift.Error {
    case missingCredentials
  }
}
