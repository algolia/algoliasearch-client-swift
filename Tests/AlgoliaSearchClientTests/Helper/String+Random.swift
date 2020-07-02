//
//  String+Random.swift
//  
//
//  Created by Vladislav Fitc on 21/04/2020.
//

import Foundation

extension String {
  
  init(randomWithLength length: Int) {
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)
    var randomString = ""
    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    self = randomString
  }
  
  static var random: String { .random(length: .random(in: 1...30)) }
  static func random(length: Int) -> String { .init(randomWithLength: length) }
  
}
