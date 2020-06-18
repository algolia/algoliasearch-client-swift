//
//  KeyedDecodingContainer+DateFormat.swift
//  
//
//  Created by Vladislav Fitc on 29/05/2020.
//

import Foundation

extension KeyedDecodingContainer {

  func decode(forKey key: K, dateFormat: String) throws -> Date {
    let rawDate: String = try decode(forKey: key)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    guard let date = dateFormatter.date(from: rawDate) else {
      throw DecodingError.dataCorrupted(DecodingError.Context.init(codingPath: [key], debugDescription: "Date conversion failed"))
    }
    return date
  }

  func decodeIfPresent(forKey key: K, dateFormat: String) throws -> Date? {
    guard let rawDate: String = try decodeIfPresent(forKey: key) else { return nil }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    guard let date = dateFormatter.date(from: rawDate) else {
      throw DecodingError.dataCorrupted(DecodingError.Context.init(codingPath: [key], debugDescription: "Date conversion failed"))
    }
    return date
  }

}
