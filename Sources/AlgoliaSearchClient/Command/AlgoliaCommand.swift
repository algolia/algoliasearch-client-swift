//
//  AlgoliaCommand.swift
//  
//
//  Created by Vladislav Fitc on 10.03.2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

protocol AlgoliaCommand {

  var callType: CallType { get }
  var urlRequest: URLRequest { get }
  var requestOptions: RequestOptions? { get }

}
