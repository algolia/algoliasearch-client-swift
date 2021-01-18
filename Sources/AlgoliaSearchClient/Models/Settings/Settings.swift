//
//  Settings.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation

public struct Settings: SettingsParameters {

  public typealias Key = SettingsParametersCodingKeys

  var settingsParametersStorage: SettingsParametersStorage

  public init() {
    self.settingsParametersStorage = .init()
  }

}

extension Settings: Decodable {

  public init(from decoder: Decoder) throws {
    try settingsParametersStorage = SettingsParametersStorage(from: decoder)
  }

}

extension Settings: Encodable {

  public func encode(to encoder: Encoder) throws {
    try settingsParametersStorage.encode(to: encoder)
  }

}

extension Settings: SettingsParametersStorageContainer {}

extension Settings: Builder {}
