//
//  Command.swift
//  
//
//  Created by Vladislav Fitc on 10.03.2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

enum Command {
}

extension Command {
  struct Template: AlgoliaCommand {
    let callType: CallType = .read
    let urlRequest: URLRequest = URLRequest(method: .get, path: Path.indexesV1)
    let requestOptions: RequestOptions? = nil
  }
}
