//
//  LogSubsystem.swift
//  Logy
//
//  Created by Marcos del Castillo Camacho on 27/10/2026.
//

import Synchronization

/// A library's identity in the unified log, with its own minimum level.
public final class LogSubsystem: Sendable {
    public let name: String

    #if DEBUG
    private static let defaultLevel = LogLevel.debug
    #else
    private static let defaultLevel = LogLevel.warning
    #endif

    // Atomic: read on every log call from any thread, writable at runtime.
    private let rawLevel = Atomic<Int>(defaultLevel.rawValue)

    public init(_ name: String) {
        self.name = name
    }

    /// Minimum level of everything logged in this subsystem; `.off` silences it.
    public var level: LogLevel {
        get { LogLevel(rawValue: rawLevel.load(ordering: .relaxed)) ?? Self.defaultLevel }
        set { rawLevel.store(newValue.rawValue, ordering: .relaxed) }
    }
}
