//
//  Transport.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

/**
 * Indicate whether the HTTP call performed is of type [read] (GET) or [write] (POST, PUT ..).
 * Used to determined which timeout duration to use.
 */
public enum CallType {
    case read, write
}

public enum HttpMethod: String {
  case get, post, put, delete
}

protocol Transport {
  
  func request<T: Codable>(method: HttpMethod,
                           callType: CallType,
                           path: String,
                           body: Data?,
                           requestOptions: RequestOptions?,
                           completion: @escaping ResultCallback<T>)
  
}
