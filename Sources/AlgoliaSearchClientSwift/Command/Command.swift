//
//  Command.swift
//  
//
//  Created by Vladislav Fitc on 10.03.2020.
//

import Foundation

enum Command {
}

extension Command {
  struct Template: AlgoliaCommand {
    let callType: CallType = .read
    let urlRequest: URLRequest = URLRequest(method: .get, path: "algolia.com")
    let requestOptions: RequestOptions? = nil
  }
}
