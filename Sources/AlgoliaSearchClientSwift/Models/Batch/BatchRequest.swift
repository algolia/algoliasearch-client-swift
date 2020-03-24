//
//  BatchRequest.swift
//  
//
//  Created by Vladislav Fitc on 18/03/2020.
//

import Foundation

public struct BatchRequest<T: Codable>: Codable {

  public let requests: [BatchOperation<T>]

}
