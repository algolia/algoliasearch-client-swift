//
//  KeyedEncodingContainer+DateFormat.swift
//  
//
//  Created by Vladislav Fitc on 29/05/2020.
//

import Foundation

extension KeyedEncodingContainer {

  mutating func encode(_ date: Date, forKey key: K, dateFormat: String) throws {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    let rawDate = dateFormatter.string(from: date)
    try encode(rawDate, forKey: key)
  }

  mutating func encodeIfPresent(_ date: Date?, forKey key: K, dateFormat: String) throws {
    guard let date = date else { return }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    let rawDate = dateFormatter.string(from: date)
    try encode(rawDate, forKey: key)
  }

}
