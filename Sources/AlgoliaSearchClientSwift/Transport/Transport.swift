//
//  Transport.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

protocol Transport: Credentials {

  func execute<Response: Decodable, Output>(_ command: AlgoliaCommand, transform: @escaping (Response) -> Output, completion: @escaping (Result<Output, Error>) -> Void) -> Operation & TransportTask
  func execute<Response: Decodable, Output>(_ command: AlgoliaCommand, transform: @escaping (Response) -> Output) throws -> Output

}

extension Transport {

  func execute<Output: Decodable>(_ command: AlgoliaCommand, completion: @escaping ResultCallback<Output>) -> Operation & TransportTask {
    execute(command, transform: { $0 }, completion: completion)
  }

  func execute<Output: Decodable>(_ command: AlgoliaCommand) throws -> Output {
    try execute(command, transform: { $0 })
  }

}

public typealias TransportTask = Cancellable & ProgressReporting
