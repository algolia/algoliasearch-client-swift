//
//  AssertionTestHelper.swift
//  
//
//  Created by Vladislav Fitc on 20/11/2020.
//

import Foundation

/// Our custom drop-in replacement `assertionFailure`.
///
/// This will call Swift's `assertionFailure` by default (and terminate the program).
/// But it can be changed at runtime to be tested instead of terminating.
func assertionFailure(_ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line) {
  assertionClosure(message(), file, line)
}

/// The actual function called by our custom `precondition`.
var assertionClosure: (String, StaticString, UInt) -> Void = defaultAssertionClosure
let defaultAssertionClosure = { Swift.assertionFailure($0, file: $1, line: $2) }
