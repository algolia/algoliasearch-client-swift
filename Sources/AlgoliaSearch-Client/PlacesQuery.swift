//
//  Copyright (c) 2016 Algolia
//  http://www.algolia.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/// Search parameters for Algolia Places.
///
/// + SeeAlso: `PlacesClient.search(...)`
///
@objc
public class PlacesQuery: AbstractQuery {
  // MARK: - Initialization

  /// Construct a query with the specified full text query.
  @objc public convenience init(query: String?) {
    self.init()
    self.query = query
  }

  /// Clone an existing query.
  @objc public convenience init(copy: PlacesQuery) {
    self.init(parameters: copy.parameters)
  }

  // MARK: NSCopying

  /// Support for `NSCopying`.
  ///
  /// + Note: Primarily intended for Objective-C use. Swift coders should use `init(copy:)`.
  ///
  @objc public override func copy(with _: NSZone?) -> Any {
    // NOTE: As per the docs, the zone argument is ignored.
    return PlacesQuery(copy: self)
  }

  // MARK: Serialization & parsing

  /// Parse a query from a URL query string.
  @objc
  public static func parse(_ queryString: String) -> PlacesQuery {
    let query = PlacesQuery()
    parse(queryString, into: query)
    return query
  }

  // MARK: - Parameters

  /// Full text query.
  @objc public var query: String? {
    get { return self["query"] }
    set { self["query"] = newValue }
  }

  /// Types of places that can be searched for.
  ///
  /// + SeeAlso: The `type` parameter.
  ///
  public enum `Type`: String {
    /// City.
    case city
    /// Country.
    case country
    /// Address.
    case address
    /// Bus stop.
    case busStop
    /// Train station.
    case trainStation
    /// Town hall.
    case townhall
    /// Airport.
    case airport
  }

  /// Restrict the search results to a specific type.
  /// If `nil`, searches in all types.
  /// Default: `nil`.
  ///
  public var type: Type? {
    get {
      if let rawValue = self["type"] {
        return Type(rawValue: rawValue)
      } else {
        return nil
      }
    }
    set {
      self["type"] = newValue?.rawValue
    }
  }

  /// Specifies how many results you want to retrieve per search.
  /// Default: 20.
  ///
  public var hitsPerPage: UInt? {
    get { return Query.parseUInt(self["hitsPerPage"]) }
    set { self["hitsPerPage"] = Query.buildUInt(newValue) }
  }

  /// If specified, restrict the search results to a single language.
  /// You can pass two letters country codes ([ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)).
  @objc public var language: String? {
    get { return self["language"] }
    set { self["language"] = newValue }
  }

  /// If specified, restrict the search results to a specific list of countries.
  /// You can pass two letters country codes ([ISO 3166-1](https://en.wikipedia.org/wiki/ISO_3166-1#Officially_assigned_code_elements)).
  ///
  /// Default: Search on the whole planet.
  ///
  @objc public var countries: [String]? {
    get { return Query.parseStringArray(self["countries"]) }
    set { self["countries"] = Query.buildJSONArray(newValue) }
  }

  /// Force to *first* search around a specific latitude/longitude.
  ///
  /// The default is to search around the location of the user determined via his IP address (geoip).
  ///
  @objc public var aroundLatLng: LatLng? {
    get {
      if let fields = self["aroundLatLng"]?.components(separatedBy: ",") {
        if fields.count == 2 {
          if let lat = Double(fields[0]), let lng = Double(fields[1]) {
            return LatLng(lat: lat, lng: lng)
          }
        }
      }
      return nil
    }
    set {
      self["aroundLatLng"] = newValue == nil ? nil : "\(newValue!.lat),\(newValue!.lng)"
    }
  }

  /// Whether or not to *first* search around the geolocation of the user found via his IP address.
  /// Default: `true`.
  ///
  public var aroundLatLngViaIP: Bool? {
    get { return Query.parseBool(self["aroundLatLngViaIP"]) }
    set { self["aroundLatLngViaIP"] = Query.buildBool(newValue) }
  }

  /// Applicable values for the `aroundRadius` parameter.
  public enum AroundRadius: Equatable {
    /// Specify an explicit value (in meters).
    case explicit(UInt)

    /// Compute the geo distance without filtering in a geo area.
    /// This option will be faster than specifying a big integer.
    case all

    // NOTE: Associated values disable automatic conformance to `Equatable`, so we have to implement it ourselves.
    public static func == (lhs: AroundRadius, rhs: AroundRadius) -> Bool {
      switch (lhs, rhs) {
      case let (.explicit(lhsValue), .explicit(rhsValue)): return lhsValue == rhsValue
      case (.all, .all): return true
      default: return false
      }
    }
  }

  /// Radius in meters to search around the latitude/longitutde.
  /// Otherwise a default radius is automatically computed given the area density.
  ///
  public var aroundRadius: AroundRadius? {
    get {
      if let stringValue = self["aroundRadius"] {
        if stringValue == "all" {
          return .all
        } else if let value = Query.parseUInt(stringValue) {
          return .explicit(value)
        }
      }
      return nil
    }
    set {
      if let newValue = newValue {
        switch newValue {
        case let .explicit(value): self["aroundRadius"] = Query.buildUInt(value)
        case .all: self["aroundRadius"] = "all"
        }
      } else {
        self["aroundRadius"] = nil
      }
    }
  }

  /// String marking the beginning of highlighted text in the response.
  /// Default: `<em>`.
  @objc public var highlightPreTag: String? {
    get { return self["highlightPreTag"] }
    set { self["highlightPreTag"] = newValue }
  }

  /// String marking the end of highlighted text in the response.
  /// Default: `</em>`.
  @objc public var highlightPostTag: String? {
    get { return self["highlightPostTag"] }
    set { self["highlightPostTag"] = newValue }
  }

  // MARK: - Objective-C bridges

  // ---------------------------
  // NOTE: Should not be used from Swift.
  // WARNING: Should not be documented.

  @objc(hitsPerPage)
  public var z_objc_hitsPerPage: NSNumber? {
    get { return AbstractQuery.toNumber(hitsPerPage) }
    set { hitsPerPage = newValue?.uintValue }
  }

  @objc(type)
  public var z_objc_type: String? {
    get { return type?.rawValue }
    set { type = newValue == nil ? nil : Type(rawValue: newValue!) }
  }

  @objc(aroundLatLngViaIP)
  public var z_objc_aroundLatLngViaIP: NSNumber? {
    get { return AbstractQuery.toNumber(aroundLatLngViaIP) }
    set { aroundLatLngViaIP = newValue?.boolValue }
  }

  // Special value for `aroundRadius` to compute the geo distance without filtering.
  @objc(aroundRadiusAll) public static let z_objc_aroundRadiusAll: NSNumber = NSNumber(value: UInt.max)

  @objc(aroundRadius)
  public var z_objc_aroundRadius: NSNumber? {
    get {
      if let aroundRadius = aroundRadius {
        switch aroundRadius {
        case let .explicit(value): return NSNumber(value: value)
        case .all: return Query.z_objc_aroundRadiusAll
        }
      }
      return nil
    }
    set {
      if let newValue = newValue {
        if newValue == Query.z_objc_aroundRadiusAll {
          aroundRadius = .all
        } else {
          aroundRadius = .explicit(newValue.uintValue)
        }
      } else {
        aroundRadius = nil
      }
    }
  }
}
