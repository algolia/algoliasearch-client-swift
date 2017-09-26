//
//  Copyright (c) 2015 Algolia
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


// ----------------------------------------------------------------------------
// IMPLEMENTATION NOTES
// ----------------------------------------------------------------------------
// # Typed vs untyped parameters
//
// All parameters are stored as untyped, string values. They can be
// accessed via the low-level `get` and `set` methods (or the subscript
// operator).
//
// Besides, the class provides typed properties, acting as wrappers on top
// of the untyped storage (i.e. serializing to and parsing from string
// values).
//
// # Bridgeability
//
// **This Swift client must be bridgeable to Objective-C.**
//
// Unfortunately, query parameters with primitive types (Int, Bool...) are not
// bridgeable, because all parameters are optional, and primitive optionals are
// not bridgeable to Objective-C.
//
// To avoid polluting too much the Swift interface with suboptimal types, the
// following policy is used:
//
// - Any parameter whose type is representable in Objective-C is implemented
//   directly in Swift and marked as `@objc`.
//
// - Any paramater whose type is *not* bridgeable to Objective-C is implemented
//   a first time as a Swift-only type...
//
// - ... and supplemented by an Objective-C specific artifact. To guarantee
//   optimal developer experience, this artifact is:
//
//     - Named with a `z_objc_` prefix in Swift. This makes it clear that they
//       are Objective-C specific. The leading "z" ensures they are last in
//       autocompletion.
//
//     - Exposed to Objective-C using the normal (unprefixed name).
//
//     - Not documented. This ensures that it does not appear in the reference
//       documentation.
//
// This way, each platform sees a properties with the right name and the most
// adequate type. The only drawback is the added clutter of the `z_objc_`-prefixed
// properties in Swift.
//
// There is also an edge case for the `aroundRadiusAll` constant, which is not
// documented.
//
// ## The case of enums
//
// Enums can only be bridged to Objective-C if their raw type is integral.
// We could do that, but since parameters are optional and optional value types
// cannot be bridged anyway (see above), this would be pointless: the type
// safety of the enum would be lost in the wrapping into `NSNumber`. Therefore,
// enums have a string raw value, and the Objective-C bridge uses a plain
// `NSString`.
//
// ## The case of structs
//
// Auxiliary types used for query parameters, like `LatLng` or `GeoRect`, have
// value semantics. However, structs are not bridgeable to Objective-C. Therefore
// we use plain classes (inheriting from `NSObject`) and we make them immutable.
//
// Equality comparison is implemented in those classes only for the sake of
// testability (we use comparisons extensively in unit tests).
//
// ## Annotations
//
// Properties and methods visible in Objective-C are annotated with `@objc`.
// From an implementation point of view, this is not necessary, because `Query`
// derives from `NSObject` and thus every brdigeable property/method is
// automatically bridged. We use these annotations as hints for maintainers
// (so please keep them).
//
// ----------------------------------------------------------------------------


/// A pair of (latitude, longitude).
/// Used in geo-search.
///
@objc public class LatLng: NSObject {
    // IMPLEMENTATION NOTE: Cannot be `struct` because of Objective-C bridgeability.
    
    /// Latitude.
    public let lat: Double
    
    /// Longitude.
    public let lng: Double
    
    /// Create a geo location.
    ///
    /// - parameter lat: Latitude.
    /// - parameter lng: Longitude.
    ///
    @objc public init(lat: Double, lng: Double) {
        self.lat = lat
        self.lng = lng
    }
    
    // MARK: Equatable
    
    public override func isEqual(_ object: Any?) -> Bool {
        if let rhs = object as? LatLng {
            return self.lat == rhs.lat && self.lng == rhs.lng
        } else {
            return false
        }
    }
}


/// A rectangle in geo coordinates.
/// Used in geo-search.
///
@objc public class GeoRect: NSObject {
    // IMPLEMENTATION NOTE: Cannot be `struct` because of Objective-C bridgeability.
    
    /// One of the rectangle's corners (typically the northwesternmost).
    public let p1: LatLng
    
    /// Corner opposite from `p1` (typically the southeasternmost).
    public let p2: LatLng
    
    /// Create a geo rectangle.
    ///
    /// - parameter p1: One of the rectangle's corners (typically the northwesternmost).
    /// - parameter p2: Corner opposite from `p1` (typically the southeasternmost).
    ///
    @objc public init(p1: LatLng, p2: LatLng) {
        self.p1 = p1
        self.p2 = p2
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        if let rhs = object as? GeoRect {
            return self.p1 == rhs.p1 && self.p2 == rhs.p2
        } else {
            return false
        }
    }
}


/// An abstract search query.
///
/// + Warning: This class is not meant to be used directly. Please see `Query` or `PlacesQuery` instead.
///
/// ## KVO
///
/// Every parameter is observable via KVO under its own name.
///
@objc
open class AbstractQuery : NSObject, NSCopying {
    
    // MARK: - Low-level (untyped) parameters
    
    /// Parameters, as untyped values.
    @objc public private(set) var parameters: [String: String] = [:]
    
    /// Get a parameter in an untyped fashion.
    ///
    /// - parameter name:   The parameter's name.
    /// - returns: The parameter's value, or nil if a parameter with the specified name does not exist.
    ///
    @objc public func parameter(withName name: String) -> String? {
        return parameters[name]
    }
    
    /// Set a parameter in an untyped fashion.
    /// This low-level accessor is intended to access parameters that this client does not yet support.
    ///
    /// - parameter name:   The parameter's name.
    /// - parameter value:  The parameter's value, or nill to remove it.
    ///
    @objc public func setParameter(withName name: String, to value: String?) {
        let oldValue = parameters[name]
        if value != oldValue {
            self.willChangeValue(forKey: name)
        }
        if value == nil {
            parameters.removeValue(forKey: name)
        } else {
            parameters[name] = value!
        }
        if value != oldValue {
            self.didChangeValue(forKey: name)
        }
    }
    
    /// Convenience shortcut to `parameter(withName:)` and `setParameter(withName:to:)`.
    @objc public subscript(index: String) -> String? {
        get {
            return parameter(withName: index)
        }
        set(newValue) {
            setParameter(withName: index, to: newValue)
        }
    }
    
    // MARK: -
    
    // MARK: - Miscellaneous
    
    @objc override open var description: String {
        get { return "\(String(describing: type(of: self))){\(parameters)}" }
    }
    
    // MARK: - Initialization
    
    /// Construct an empty query.
    @objc public override init() {
    }
    
    /// Construct a query with the specified low-level parameters.
    @objc public init(parameters: [String: String]) {
        self.parameters = parameters
    }

    /// Clear all parameters.
    @objc open func clear() {
        parameters.removeAll()
    }

    // MARK: NSCopying
    
    /// Support for `NSCopying`.
    ///
    /// + Note: Primarily intended for Objective-C use. Swift coders should use `init(copy:)`.
    ///
    @objc open func copy(with zone: NSZone?) -> Any {
        // NOTE: As per the docs, the zone argument is ignored.
        return AbstractQuery(parameters: self.parameters)
    }
    
    // MARK: Serialization & parsing
    
    /// Return the final query string used in URL.
    @objc open func build() -> String {
        return AbstractQuery.build(parameters: parameters)
    }

    /// Build a query string from a set of parameters.
    @objc static public func build(parameters: [String: String]) -> String {
        var components = [String]()
        // Sort parameters by name to get predictable output.
        let sortedParameters = parameters.sorted { $0.0 < $1.0 }
        for (key, value) in sortedParameters {
            let escapedKey = key.urlEncodedQueryParam()
            let escapedValue = value.urlEncodedQueryParam()
            components.append(escapedKey + "=" + escapedValue)
        }
        return components.joined(separator: "&")
    }
    
    internal static func parse(_ queryString: String, into query: AbstractQuery) {
        let components = queryString.components(separatedBy: "&")
        for component in components {
            let fields = component.components(separatedBy: "=")
            if fields.count < 1 || fields.count > 2 {
                continue
            }
            if let name = fields[0].removingPercentEncoding {
                let value: String? = fields.count >= 2 ? fields[1].removingPercentEncoding : nil
                if value == nil {
                    query.parameters.removeValue(forKey: name)
                } else {
                    query.parameters[name] = value!
                }
            }
        }
    }
    
    // MARK: Equatable
    
    override open func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? AbstractQuery else {
            return false
        }
        return self.parameters == rhs.parameters
    }
    
    // MARK: - Helper methods to build & parse URL
    
    /// Build a plain, comma-separated array of strings.
    ///
    internal static func buildStringArray(_ array: [String]?) -> String? {
        if array != nil {
            return array!.joined(separator: ",")
        }
        return nil
    }
    
    internal static func parseStringArray(_ string: String?) -> [String]? {
        if string != nil {
            // First try to parse the JSON notation:
            do {
                if let array = try JSONSerialization.jsonObject(with: string!.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String] {
                    return array
                }
            } catch {
            }
            // Fallback on plain string parsing.
            return string!.components(separatedBy: ",")
        }
        return nil
    }
    
    internal static func buildJSONArray(_ array: [Any]?) -> String? {
        if array != nil {
            do {
                let data = try JSONSerialization.data(withJSONObject: array!, options: JSONSerialization.WritingOptions(rawValue: 0))
                if let string = String(data: data, encoding: String.Encoding.utf8) {
                    return string
                }
            } catch {
            }
        }
        return nil
    }
    
    internal static func parseJSONArray(_ string: String?) -> [Any]? {
        if string != nil {
            do {
                if let array = try JSONSerialization.jsonObject(with: string!.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [Any] {
                    return array
                }
            } catch {
            }
        }
        return nil
    }
    
    internal static func buildUInt(_ int: UInt?) -> String? {
        return int == nil ? nil : String(int!)
    }
    
    internal static func parseUInt(_ string: String?) -> UInt? {
        if string != nil {
            if let intValue = UInt(string!) {
                return intValue
            }
        }
        return nil
    }
    
    internal static func buildBool(_ bool: Bool?) -> String? {
        return bool == nil ? nil : String(bool!)
    }
    
    internal static func parseBool(_ string: String?) -> Bool? {
        if string != nil {
            switch (string!.lowercased()) {
            case "true": return true
            case "false": return false
            default:
                if let intValue = Int(string!) {
                    return intValue != 0
                }
            }
        }
        return nil
    }
    
    internal static func toNumber(_ bool: Bool?) -> NSNumber? {
        return bool == nil ? nil : NSNumber(value: bool!)
    }
    
    internal static func toNumber(_ int: UInt?) -> NSNumber? {
        return int == nil ? nil : NSNumber(value: int!)
    }
}
