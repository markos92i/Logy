//
//  LogEntry.swift
//  Logy
//
//  Created by Marcos del Castillo Camacho on 27/10/2026.
//

/// Something a library logs: usually one enum per library, one case per event.
public protocol LogEntry: Sendable {
    var level: LogLevel { get }
    var channel: LogChannel { get }
    /// `bodies` is `true` when the effective level is `.debug`.
    @LogBuilder func lines(bodies: Bool) -> [String]
}

extension LogEntry {
    /// The text that reaches the log: the first line aligned in columns.
    public func rendered(bodies: Bool) -> String {
        var lines = lines(bodies: bodies)
        if !lines.isEmpty { lines[0] = LogColumns.align(lines[0]) }
        return lines.joined(separator: "\n")
    }
}
