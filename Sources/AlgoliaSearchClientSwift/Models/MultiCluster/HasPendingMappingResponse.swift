//
//  HasPendingMappingResponse.swift
//  
//
//  Created by Vladislav Fitc on 25/05/2020.
//

import Foundation

public struct HasPendingMappingResponse: Codable {
  
  let isPending: Bool
  let clusters: [ClusterName: [UserID]]?
  
}
