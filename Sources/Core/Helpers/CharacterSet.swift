//
//  CharacterSet.swift
//
//
//  Created by Algolia on 22/01/2024.
//

import Foundation

public extension CharacterSet {
    static let urlPathAlgoliaAllowed: CharacterSet = .alphanumerics.union(
        .init(charactersIn: "-._~!'()*"))
}
