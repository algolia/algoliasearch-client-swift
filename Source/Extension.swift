//
//  ArrayShuffle.swift
//  AlgoliaSearch
//
//  Created by Thibault Deutsch on 13/02/15.
//  Copyright (c) 2015 Algolia. All rights reserved.
//

import Foundation

extension Array {
    /// Shuffle the array
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&self[i], &self[j])
        }
    }
}

extension String {
    /// Return URL encoded version of the string
    func urlEncode() -> String {
        let customAllowedSet = NSCharacterSet(charactersInString: "!*'();:@&=+$,/?%#[]").invertedSet
        return stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
    }
}