//
//  Version.swift
//
//
//  Created by Vladislav Fitc on 14/04/2020.
//

public struct Version {

  public let major: Int
  public let minor: Int
  public let patch: Int
  public let prereleaseIdentifier: String?

  public init(major: Int, minor: Int, patch: Int = 0, prereleaseIdentifier: String? = nil) {
    self.major = major
    self.minor = minor
    self.patch = patch
    self.prereleaseIdentifier = prereleaseIdentifier
  }

}

extension Version: CustomStringConvertible {

  public var description: String {
    let main = [major, minor, patch].map(String.init).joined(separator: ".")
    if let prereleaseIdentifier = prereleaseIdentifier {
      return main + "-\(prereleaseIdentifier)"
    } else {
      return main
    }
  }

}
