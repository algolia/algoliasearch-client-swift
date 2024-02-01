//
//  Transport.swift
//
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

protocol Transport: Credentials {
  func execute<Command: AlgoliaCommand, Response: Decodable, Output>(
    _ command: Command, transform: @escaping (Response) -> Output,
    completion: @escaping (Result<Output, Error>) -> Void
  ) -> Operation & TransportTask
  func execute<Command: AlgoliaCommand, Response: Decodable, Output>(
    _ command: Command, transform: @escaping (Response) -> Output
  ) throws -> Output
}

extension Transport {
  func execute<T: Decodable>(_ command: some AlgoliaCommand, completion: @escaping ResultCallback<T>) -> Operation & TransportTask {
    execute(command, transform: { $0 }, completion: completion)
  }

  func execute<Output: Decodable>(_ command: some AlgoliaCommand) throws -> Output {
    try execute(command, transform: { $0 })
  }
}

public typealias TransportTask = Cancellable & ProgressReporting
