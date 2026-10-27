//
//  LogFormatting.swift
//  Logy
//
//  Created by Marcos del Castillo Camacho on 27/10/2026.
//

import Foundation

extension Int {
    /// `2KB`, `1,5MB`: a byte count without the space.
    public var byteFormatted: String {
        ByteCountFormatter.string(fromByteCount: Int64(self), countStyle: .file)
            .replacingOccurrences(of: " ", with: "")
    }
}

extension Duration {
    /// `1s 500ms`, `1min 5s`: at most two units, without the space before each unit.
    public var logFormatted: String {
        let raw = formatted(.units(
            allowed: [.hours, .minutes, .seconds, .milliseconds],
            width: .narrow,
            maximumUnitCount: 2,
            fractionalPart: .hide
        ))
        return raw.replacingOccurrences(of: #"(\d)\s+([\w])"#, with: "$1$2", options: .regularExpression)
    }
}

extension Data {
    /// Pretty-printed when it's JSON, UTF-8 otherwise; `nil` when it isn't text.
    public var logText: String? {
        guard first == 0x7B || first == 0x5B,
              let object = try? JSONSerialization.jsonObject(with: self),
              let pretty = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
        else { return String(data: self, encoding: .utf8) }
        return String(data: pretty, encoding: .utf8)
    }
}
