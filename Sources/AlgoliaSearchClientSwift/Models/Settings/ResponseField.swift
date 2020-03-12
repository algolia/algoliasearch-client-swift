//
//  ResponseField.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation

enum ResponseField: String, Codable {
  case all = "*"
  case aroundLatLng
  case automaticRadius
  case exhaustiveFacetsCount
  case facets
  case facetsStats = "facets_stats"
  case hits
  case hitsPerPage
  case index
  case length
  case nbHits
  case nbPages
  case offset
  case page
  case params
  case processingTimeMS
  case query
  case queryAfterRemoval
  case userData
}
