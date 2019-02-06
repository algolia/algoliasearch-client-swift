//
//  AbstractClass.swift
//  AlgoliaSearch
//
//  Created by Vladislav Fitc on 06/02/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation

protocol AbstractClass {
    static func callMustOverrideError() -> Never
    static func impossibleInitError() -> Never
}

extension AbstractClass {
    
    static func callMustOverrideError() -> Never {
        fatalError("Must override")
    }
    
    static func impossibleInitError() -> Never {
        fatalError("\(String(describing: self)) instances can not be created; create a subclass instance instead")
    }
    
    func callMustOverrideError() -> Never {
        Self.callMustOverrideError()
    }
    
    func impossibleInitError() -> Never {
        Self.impossibleInitError()
    }
    
}
