//
//  File.swift
//  
//
//  Created by Vladislav Fitc on 12/04/2020.
//

import Foundation

enum PlaceCodingKeys: String, CodingKey {
  case country
  case county
  case city
  case localeNames = "locale_names"
  case administrative
  case countryCode = "country_code"
  case postcode
  case population
  case importance
  case tags = "_tags"
  case adminLevel = "admin_level"
  case district
  case suburb
  case village
  case isCountry = "is_country"
  case isCity = "is_city"
  case isSuburb = "is_suburb"
  case isHighway = "is_highway"
  case isPopular = "is_popular"
}
