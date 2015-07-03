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

public typealias CompletionHandler = (content: [String: AnyObject]?, error: NSError?) -> Void

struct RingBuffer<T>: SequenceType {
    typealias Generator = IndexingGenerator<Array<T>>
    private var buff: [T]
    private var capacity: Int
    private var index = 0
    
    private var isFull: Bool {
        return buff.count >= capacity
    }
    
    init(maxCapacity: Int) {
        buff = [T]()
        buff.reserveCapacity(maxCapacity)
        capacity = maxCapacity
    }
    
    func generate() -> Generator {
        return buff.generate()
    }
    
    mutating func append(newElement: T) {
        if !isFull {
            buff.append(newElement)
        } else {
            buff[index % capacity] = newElement
        }
        ++index
    }
}