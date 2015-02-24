//
//  Type.swift
//  AlgoliaSearch
//
//  Created by Thibault Deutsch on 24/02/15.
//  Copyright (c) 2015 Algolia. All rights reserved.
//

import Foundation

public typealias CompletionHandlerType = (JSON: AnyObject?, error: NSError?) -> Void?

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