//
//  ResultCallback.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

typealias ResultCallback<T: Codable> = (Result<T, Error>) -> Void
