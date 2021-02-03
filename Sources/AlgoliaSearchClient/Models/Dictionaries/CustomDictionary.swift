//
//  CustomDictionary.swift
//  
//
//  Created by Vladislav Fitc on 25/01/2021.
//

import Foundation

public protocol CustomDictionary {

  associatedtype Entry: DictionaryEntry

  static var name: DictionaryName { get }

}
