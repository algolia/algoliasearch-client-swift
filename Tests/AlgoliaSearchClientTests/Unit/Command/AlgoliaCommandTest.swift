//
//  AlgoliaCommandTest.swift
//
//
//  Created by Vladislav Fitc on 26/03/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

protocol AlgoliaCommandTest {

  var test: TestValues { get }
  func check<Command: AlgoliaCommand>(command: Command, callType: CallType, method: HTTPMethod, urlPath: String, queryItems: Set<URLQueryItem>, body: Data?, additionalHeaders: [HTTPHeaderKey: String]?, requestOptions: RequestOptions, file: StaticString, line: UInt)

}

extension AlgoliaCommandTest {

  var test: TestValues {
    return TestValues()
  }

  func check<Command: AlgoliaCommand>(command: Command, callType: CallType, method: HTTPMethod, urlPath: String, queryItems: Set<URLQueryItem>, body: Data?, additionalHeaders: [HTTPHeaderKey: String]? = nil, requestOptions: RequestOptions, file: StaticString = #file, line: UInt = #line) {
    
    let request = URLRequest(command: command)
    XCTAssertEqual(command.callType, callType, file: file, line: line)
    XCTAssertEqual(request.httpMethod, method.rawValue, file: file, line: line)
    XCTAssertEqual(request.url?.path, urlPath, file: file, line: line)
    
    let requestQueryItems = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?.queryItems ?? []

    #if canImport(FoundationNetworking)
    XCTAssertEqual(request.allHTTPHeaderFields?.mapKeys { $0.lowercased() }, requestOptions.headers.merging(additionalHeaders ?? [:]).mapKeys { $0.rawValue.lowercased() }, file: file, line: line)
    
    for item in queryItems {
      XCTAssertTrue(requestQueryItems.contains(where: { $0.name.lowercased() == item.name.lowercased() && $0.value == item.value }) , file: file, line: line)
    }

    let jsonDecoder = JSONDecoder()
    func dataToJSON(_ data: Data) throws -> JSON { try jsonDecoder.decode(JSON.self, from: data) }
    try XCTAssertEqual(request.httpBody.flatMap(dataToJSON), body.flatMap(dataToJSON), file: file, line: line)
    #else
    XCTAssertEqual(request.allHTTPHeaderFields, requestOptions.headers.merging(additionalHeaders ?? [:]).mapKeys { $0.rawValue }, file: file, line: line)
    XCTAssertTrue(Set(requestQueryItems).isSuperset(of: queryItems), file: file, line: line)
    AssertJSONEqual(request.httpBody, body)
    #endif
  }

}


extension Data {
    /// Converts the Data to a hexadecimal string representation.
    func toHexString() -> String {
        return map { String(format: "%02x", $0) }.joined()
    }
  
    func toJsonString() -> String? {
      do {
        // Convert the Data object to a JSON object
        let jsonObject = try JSONSerialization.jsonObject(with: self, options: [])
        
        // Convert the JSON object to a pretty-printed JSON string
        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
        
        return String(data: jsonData, encoding: .utf8)
      } catch {
        print("Error converting Data to JSON String: \(error)")
        return nil
      }
    }
}
