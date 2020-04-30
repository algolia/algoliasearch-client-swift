//
//  ResultCallback.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

public typealias ResultCallback<T> = (Result<T, Error>) -> Void
public typealias ResultTaskCallback<T: Task & Codable> = (Result<WaitableWrapper<T>, Error>) -> Void
public typealias ResultBatchesCallback = (Result<WaitableWrapper<BatchesResponse>, Error>) -> Void
