//
//  Optional+Throw.swift
//  
//
//  Created by Vladislav Fitc on 02/06/2020.
//

import Foundation

extension Optional {
  
    func orThrow(_ errorExpression: @autoclosure () -> Error) throws -> Wrapped {
        switch self {
        case .some(let value):
            return value
        case .none:
            throw errorExpression()
        }
    }
  
}
