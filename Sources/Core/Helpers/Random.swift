//
//  Random.swift
//
//
//  Created by Algolia on 22/02/2024.
//

import Foundation

public func randomString(length: Int = 10) throws -> String {
    let characterSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

    return String((0 ..< length).compactMap { _ in characterSet.randomElement() })
}
