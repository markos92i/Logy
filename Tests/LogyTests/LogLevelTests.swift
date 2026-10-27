//
//  LogLevelTests.swift
//  Logy
//
//  Created by Marcos del Castillo Camacho on 27/10/2026.
//

import Testing
@testable import Logy

@Suite("LogLevel")
struct LogLevelTests {
    @Test func ordersBySeverity() {
        #expect(LogLevel.debug < .info)
        #expect(LogLevel.info < .warning)
        #expect(LogLevel.warning < .error)
        #expect(LogLevel.error < .off)
    }

    @Test func warningAndErrorReachTheUnifiedLogAsError() {
        #expect(LogLevel.warning.osLogType == .error)
        #expect(LogLevel.error.osLogType == .error)
        #expect(LogLevel.debug.osLogType == .debug)
        #expect(LogLevel.info.osLogType == .info)
    }
}
