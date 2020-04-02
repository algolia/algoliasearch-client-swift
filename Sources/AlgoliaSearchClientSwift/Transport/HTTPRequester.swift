//
//  HTTPRequester.swift
//  
//
//  Created by Vladislav Fitc on 19/03/2020.
//

import Foundation

protocol HTTPRequester {

  func perform<T: Codable>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> TransportTask

}
