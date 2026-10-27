//
//  Logy.swift
//  Logy
//
//  Created by Marcos del Castillo Camacho on 27/10/2026.
//

import os

/// Writes a library's entries to the unified log.
public struct Logy<Entry: LogEntry>: Sendable {
    /// Overrides the subsystem's level for this owner (e.g. one API); `nil` follows the subsystem.
    public let level: LogLevel?

    public init(level: LogLevel? = nil) {
        self.level = level
    }

    public func log(_ entry: Entry) {
        let global = entry.channel.subsystem.level
        guard logs(entry.level, global: global) else { return }
        // Bodies are debug detail.
        emit(entry.rendered(bodies: logs(.debug, global: global)), to: entry.channel.logger, type: entry.level.osLogType)
    }

    /// A subsystem at `.off` silences every owner, also one with its own level.
    func logs(_ entryLevel: LogLevel, global: LogLevel) -> Bool {
        global != .off && (level ?? global) <= entryLevel
    }

    /// Output may hold personal data: public only in Debug. `privacy:` must be a literal.
    private func emit(_ output: String, to logger: os.Logger, type: OSLogType) {
        #if DEBUG
        logger.log(level: type, "\(output, privacy: .public)")
        #else
        logger.log(level: type, "\(output, privacy: .private)")
        #endif
    }
}
