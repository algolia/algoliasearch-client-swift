//
//  SynonymType.swift
//  
//
//  Created by Vladislav Fitc on 20/05/2020.
//

import Foundation

public enum SynonymType: String, Codable {
  case multiWay = "synonym"
  case oneWay = "oneWaySynonym"
  case altCorrection1
  case altCorrection2
  case placeholder
}
