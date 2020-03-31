//
//  RequestParams.swift
//  
//
//  Created by Vladislav Fitc on 28/03/2020.
//

import Foundation

struct RequestParams<T: Codable>: Codable {
  
  let params: T
  
  init(_ content: T) {
    self.params = content
  }
  
}
