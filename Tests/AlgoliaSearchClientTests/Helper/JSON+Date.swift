//
//  JSON+Date.swift
//  AlgoliaSearchClient
//
//  Created by Vladislav Fitc on 07/04/2020.
//

import Foundation

@testable import AlgoliaSearchClient

extension JSON {
  init(_ date: Date, encodingStrategy: JSONEncoder.DateEncodingStrategy = .swiftAPIClient) {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = encodingStrategy
    let dateData = try! encoder.encode(date)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .swiftAPIClient
    self = .string(try! decoder.decode(String.self, from: dateData))
  }
}
