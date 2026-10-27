//
//  LogLevel.swift
//  Logy
//
//  Created by Marcos del Castillo Camacho on 27/10/2026.
//

import os

/// Log severity level.
public enum LogLevel: Int, Sendable, Comparable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    case off = 4

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// Same mapping as `os.Logger`: `.fault` is for process bugs, not failed operations.
    var osLogType: OSLogType {
        switch self {
        case .debug:   .debug
        case .info:    .info
        case .warning: .error
        case .error:   .error
        case .off:     .info
        }
    }
}
