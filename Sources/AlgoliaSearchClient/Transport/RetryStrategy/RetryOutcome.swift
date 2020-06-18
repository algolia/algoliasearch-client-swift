//
//  RetryOutcome.swift
//  
//
//  Created by Vladislav Fitc on 20/02/2020.
//

import Foundation

enum RetryOutcome<T> {
  case success(T), retry, failure(Error)
}
