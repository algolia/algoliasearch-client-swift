//
//  MultiLanguagePlace.swift
//  
//
//  Created by Vladislav Fitc on 12/04/2020.
//

import Foundation

public struct CustomKey<Key: Hashable & RawRepresentable, Value: Codable>: Codable where Key.RawValue == String {
  
  public var wrappedValue: [Key: Value]
  
  public init(wrappedValue: [Key: Value]) {
    self.wrappedValue = wrappedValue
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicKey.self)
    var storage: [Key: Value] = [:]
    for rawKey in container.allKeys {
      guard let key = Key(rawValue: rawKey.stringValue) else { throw DecodingError.dataCorruptedError(forKey: rawKey, in: container, debugDescription: "Cannot create \(Value.self) value") }
      let value = try container.decode(Value.self, forKey: rawKey)
      storage[key] = value
    }
    self.wrappedValue = storage
  }
  
  public func encode(to encoder: Encoder) throws {
    let rawWrappedSequence = wrappedValue.map { ($0.key.rawValue, $0.value) }
    let rawWrappedValue = [String: Value](rawWrappedSequence) { (_, k) in k }
    try rawWrappedValue.encode(to: encoder)
  }
  
}

public struct MultiLanguagePlace {
  
  public let country: [Language: String]?
  public let county: [Language: [String]]?
  public let city: [Language: [String]]?
  public let localeNames: [Language: [String]]?
  public let administrative: [String]?
  public let countryCode: Country?
  public let postcode: [String]?
  public let population: Double?
  public let importance: Int?
  public let tags: [String]?
  public let adminLevel: Int?
  public let district: String?
  public let suburb: [String]?
  public let village: [String]?
  public let isCountry: Bool?
  public let isCity: Bool?
  public let isSuburb: Bool?
  public let isHighway: Bool?
  public let isPopular: Bool?
  
}

extension MultiLanguagePlace: Codable {
  
  typealias CodingKeys = PlaceCodingKeys
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    country = (try container.decodeIfPresent(CustomKey<Language, String>.self, forKey: .country))?.wrappedValue
    county = (try container.decodeIfPresent(CustomKey<Language, [String]>.self, forKey: .county))?.wrappedValue
    city = (try container.decodeIfPresent(CustomKey<Language, [String]>.self, forKey: .city))?.wrappedValue
    localeNames = (try container.decodeIfPresent(CustomKey<Language, [String]>.self, forKey: .localeNames))?.wrappedValue
    administrative = try container.decodeIfPresent(forKey: .administrative)
    countryCode = try container.decodeIfPresent(forKey: .countryCode)
    postcode = try container.decodeIfPresent(forKey: .postcode)
    population = try container.decodeIfPresent(forKey: .population)
    importance = try container.decodeIfPresent(forKey: .importance)
    tags = try container.decodeIfPresent(forKey: .tags)
    adminLevel = try container.decodeIfPresent(forKey: .adminLevel)
    district = try container.decodeIfPresent(forKey: .district)
    suburb = try container.decodeIfPresent(forKey: .suburb)
    village = try container.decodeIfPresent(forKey: .village)
    isCountry = try container.decodeIfPresent(forKey: .isCountry)
    isCity = try container.decodeIfPresent(forKey: .isCity)
    isSuburb = try container.decodeIfPresent(forKey: .isSuburb)
    isHighway = try container.decodeIfPresent(forKey: .isHighway)
    isPopular = try container.decodeIfPresent(forKey: .isPopular)
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(country, forKey: .country)
    try container.encodeIfPresent(county, forKey: .county)
    try container.encodeIfPresent(city, forKey: .city)
    try container.encodeIfPresent(localeNames, forKey: .localeNames)
    try container.encodeIfPresent(administrative, forKey: .administrative)
    try container.encodeIfPresent(countryCode, forKey: .countryCode)
    try container.encodeIfPresent(postcode, forKey: .postcode)
    try container.encodeIfPresent(population, forKey: .population)
    try container.encodeIfPresent(importance, forKey: .importance)
    try container.encodeIfPresent(tags, forKey: .tags)
    try container.encodeIfPresent(adminLevel, forKey: .adminLevel)
    try container.encodeIfPresent(district, forKey: .district)
    try container.encodeIfPresent(suburb, forKey: .suburb)
    try container.encodeIfPresent(village, forKey: .village)
    try container.encodeIfPresent(isCountry, forKey: .isCountry)
    try container.encodeIfPresent(isCity, forKey: .isCity)
    try container.encodeIfPresent(isSuburb, forKey: .isSuburb)
    try container.encodeIfPresent(isHighway, forKey: .isHighway)
    try container.encodeIfPresent(isPopular, forKey: .isPopular)
  }
    
}
