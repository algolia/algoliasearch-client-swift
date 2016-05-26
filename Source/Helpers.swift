//
//  Copyright (c) 2015 Algolia
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

extension String {
    /// Return URL encoded version of the string
    func urlEncode() -> String {
        let customAllowedSet = NSCharacterSet(charactersInString: "!*'();:@&=+$,/?%#[]").invertedSet
        return stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
    }
}

// MARK: - Memory debugging

// NOTE: Those helpers are not used in the code, but let's keep them because they can be handy when debugging.

/// Log the initialization of an object.
func logInit(object: AnyObject) {
    print("<INIT> \(unsafeAddressOf(object)) (\(object.dynamicType)) \(object.description)")
}

/// Log the termination ("de-initialization" in Swift terms) of an object.
func logTerm(object: AnyObject) {
    print("<TERM> \(unsafeAddressOf(object)) (\(object.dynamicType)) \(object.description)")

// MARK: - Collection shuffling
// Taken from <http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift>.

extension CollectionType {
    /// Return a copy of `self` with its elements shuffled.
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // Empty and single-element collections don't shuffle.
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}
