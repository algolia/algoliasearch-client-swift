//
//  String+Random.swift
//  
//
//  Created by Vladislav Fitc on 21/04/2020.
//

import Foundation

extension String {
  
  init(randomWithLength length: Int) {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    self = String((0..<length).compactMap { _ in letters.randomElement() })
  }
  
  static var random: String { .random(length: .random(in: 1...30)) }
  static func random(length: Int) -> String { .init(randomWithLength: length) }
  
}
