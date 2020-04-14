//
//  Language.swift
//  
//
//  Created by Vladislav Fitc on 12.03.2020.
//

import Foundation

public struct Language: StringOption & ProvidingCustomOption & Hashable & ExpressibleByStringLiteral {
  public typealias StringLiteralType = String
  
  public var rawValue: String
  public init(rawValue: String) { self.rawValue = rawValue }
  public init(stringLiteral: String) { self.rawValue = stringLiteral }
  
  static let afrikaans: Self = "af"
  static let arabic: Self = "ar"
  static let azeri: Self = "az"
  static let bulgarian: Self = "bg"
  static let brunei: Self = "bn"
  static let catalan: Self = "ca"
  static let czech: Self = "cs"
  static let welsh: Self = "cy"
  static let danish: Self = "da"
  static let german: Self = "de"
  static let english: Self = "en"
  static let esperanto: Self = "eo"
  static let spanish: Self = "es"
  static let estonian: Self = "et"
  static let basque: Self = "eu"
  static let finnish: Self = "fi"
  static let faroese: Self = "fo"
  static let french: Self = "fr"
  static let galician: Self = "gl"
  static let hebrew: Self = "he"
  static let hindi: Self = "hi"
  static let hungarian: Self = "hu"
  static let armenian: Self = "hy"
  static let indonesian: Self = "id"
  static let icelandic: Self = "is"
  static let italian: Self = "it"
  static let japanese: Self = "ja"
  static let georgian: Self = "ka"
  static let kazakh: Self = "kk"
  static let korean: Self = "ko"
  static let kyrgyz: Self = "ky"
  static let lithuanian: Self = "lt"
  static let maori: Self = "mi"
  static let mongolian: Self = "mn"
  static let marathi: Self = "mr"
  static let malay: Self = "ms"
  static let maltese: Self = "mt"
  static let norwegian: Self = "nb"
  static let dutch: Self = "nl"
  static let northernsotho: Self = "ns"
  static let polish: Self = "pl"
  static let pashto: Self = "ps"
  static let portuguese: Self = "pt"
  static let quechua: Self = "qu"
  static let romanian: Self = "ro"
  static let russian: Self = "ru"
  static let slovak: Self = "sk"
  static let albanian: Self = "sq"
  static let swedish: Self = "sv"
  static let swahili: Self = "sw"
  static let tamil: Self = "ta"
  static let telugu: Self = "te"
  static let tagalog: Self = "tl"
  static let tswana: Self = "tn"
  static let turkish: Self = "tr"
  static let tatar: Self = "tt"
}
