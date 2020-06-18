//
//  Encodable+HTTPBody.swift
//  
//
//  Created by Vladislav Fitc on 19/03/2020.
//

import Foundation

extension Encodable {

  var httpBody: Data {
    let jsonEncoder = JSONEncoder()
    jsonEncoder.dateEncodingStrategy = .swiftAPIClient
    do {
      let body = try jsonEncoder.encode(self)
      return body
    } catch let error {
      assertionFailure("\(error)")
      return Data()
    }
  }

}
