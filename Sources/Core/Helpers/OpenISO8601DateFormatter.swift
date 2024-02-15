//
// OpenISO8601DateFormatter.swift
//
// Created by Algolia on 08/01/2024
//

import Foundation

/// https://stackoverflow.com/a/50281094/976628
public class OpenISO8601DateFormatter: DateFormatter {
    // MARK: Lifecycle

    override init() {
        super.init()
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    // MARK: Public

    override public func date(from string: String) -> Date? {
        if let result = super.date(from: string) {
            return result
        } else if let result = OpenISO8601DateFormatter.withoutSeconds.date(from: string) {
            return result
        }

        return OpenISO8601DateFormatter.withoutTime.date(from: string)
    }

    // MARK: Internal

    static let withoutSeconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
    }()

    static let withoutTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    // MARK: Private

    private func setup() {
        calendar = Calendar(identifier: .iso8601)
        locale = Locale(identifier: "en_US_POSIX")
        timeZone = TimeZone(secondsFromGMT: 0)
        dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    }
}
