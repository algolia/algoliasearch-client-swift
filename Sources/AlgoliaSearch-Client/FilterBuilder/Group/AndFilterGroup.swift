//
//  AndFilterGroup.swift
//  AlgoliaSearch OSX
//
//  Created by Vladislav Fitc on 14/01/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation

public struct AndFilterGroup: FilterGroup {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
    
    public static func and(_ name: String) -> AndFilterGroup {
        return AndFilterGroup(name: name)
    }
    
}
