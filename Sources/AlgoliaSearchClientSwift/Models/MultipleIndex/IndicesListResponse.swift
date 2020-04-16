//
//  IndicesListResponse.swift
//  
//
//  Created by Vladislav Fitc on 04/04/2020.
//

import Foundation

public struct IndicesListResponse: Codable {

  let items: [Item]

  /**
   The value is always 1.
   There is currently no pagination for this method. Every index is returned on the first call.
  */
  let nbPages: Int

}

extension IndicesListResponse {

  public struct Item: Codable {
  }

}
