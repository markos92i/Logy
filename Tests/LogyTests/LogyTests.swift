//
//  LogyTests.swift
//  Logy
//
//  Created by Marcos del Castillo Camacho on 27/10/2026.
//

import Foundation
import Testing
@testable import Logy

private extension LogSubsystem { static let test = LogSubsystem("com.logy.test") }
private extension LogChannel { static let test = LogChannel(.test, "test") }

private enum TestEntry: LogEntry {
    case event(id: String, detail: String?)
    case payload(Data)

    var level: LogLevel { .info }
    var channel: LogChannel { .test }

    func lines(bodies: Bool) -> [String] {
        switch self {
        case .event(let id, let detail):
            "􀁶 \(id)\tsecond\tthird"
            if let detail { "􀺾 \(detail)" }
        case .payload(let data):
            "􁒡 \(bodies ? data.logText ?? "" : data.count.byteFormatted)"
        }
    }
}

@Suite("Logy")
struct LogyTests {

    // MARK: - Levels

    @Test func anOwnerLevelOverridesTheSubsystem() {
        #expect(Logy<TestEntry>(level: .debug).logs(.debug, global: .warning))
        #expect(!Logy<TestEntry>(level: .info).logs(.debug, global: .debug))
        #expect(Logy<TestEntry>().logs(.warning, global: .warning))
        #expect(!Logy<TestEntry>().logs(.info, global: .warning))
    }

    @Test func aSubsystemAtOffSilencesAnOwnerWithItsOwnLevel() {
        #expect(!Logy<TestEntry>(level: .debug).logs(.error, global: .off))
        #expect(!Logy<TestEntry>().logs(.error, global: .off))
        #expect(!Logy<TestEntry>(level: .off).logs(.error, global: .debug))
    }

    @Test func aSubsystemLevelChangesAtRuntime() {
        let subsystem = LogSubsystem("com.logy.runtime")
        subsystem.level = .error
        #expect(subsystem.level == .error)
        subsystem.level = .off
        #expect(subsystem.level == .off)
    }

    // MARK: - Rendering

    @Test func onlyTheFirstLineIsAligned() {
        let text = TestEntry.event(id: "A1F3", detail: "a\tb").rendered(bodies: false)
        let lines = text.split(separator: "\n")
        #expect(lines.count == 2)
        #expect(!lines[0].contains("\t"))
        #expect(lines[1] == "􀺾 a\tb")
    }

    @Test func theBuilderSkipsAMissingLine() {
        #expect(TestEntry.event(id: "A1F3", detail: nil).rendered(bodies: false).split(separator: "\n").count == 1)
    }

    @Test func bodiesAreShownOnlyWhenAsked() {
        let entry = TestEntry.payload(Data(#"{"name":"Ana"}"#.utf8))
        #expect(entry.rendered(bodies: true).contains("Ana"))
        #expect(!entry.rendered(bodies: false).contains("Ana"))
    }

    // MARK: - Columns

    /// A value longer than its column pushes the next one, which never gets closer than the gap.
    @Test func aLongColumnKeepsTheGap() {
        #expect(LogColumns.align("a\tb") == "a" + String(repeating: " ", count: 6 + LogColumns.gap) + "b")
        #expect(LogColumns.align("abcdefghij\tb") == "abcdefghij" + String(repeating: " ", count: LogColumns.gap) + "b")
        #expect(LogColumns.align("􀁶 A1F3\tb") == "􀁶 A1F3" + String(repeating: " ", count: LogColumns.gap) + "b")
        #expect(LogColumns.align("a\t") == "a")
    }

    // MARK: - Formatting

    @Test func formatsBytesDurationsAndText() {
        #expect(2048.byteFormatted == "2KB")
        #expect(Duration.milliseconds(1500).logFormatted == "1s 500ms")
        #expect(Data(#"{"a":1}"#.utf8).logText == "{\n  \"a\" : 1\n}")
        #expect(Data("plain".utf8).logText == "plain")
        #expect(Data("{not json".utf8).logText == "{not json")
        #expect(Data([0xFF, 0xFE]).logText == nil)
    }

    // MARK: - Measurements

    @Test func measureReturnsTheValueAndTheTimeItTook() async {
        let log = Logy<TestEntry>()
        let pause = Duration.milliseconds(20)
        let (value, elapsed) = await log.measure("work", "test", on: .test) { () async -> Int in
            try? await Task.sleep(for: pause)
            return 42
        }
        #expect(value == 42)
        #expect(elapsed >= pause)
    }

    @Test func measureRethrowsTheTypedError() async {
        struct Failure: Error {}
        let log = Logy<TestEntry>()
        await #expect(throws: Failure.self) {
            try await log.measure("work", "test", on: .test) { () async throws(Failure) -> Int in throw Failure() }
        }
    }

    @Test func measureRunsOnTheCallersActor() async {
        actor Counter {
            let log = Logy<TestEntry>()
            var count = 0
            func increment() async -> Int {
                let (value, _) = await log.measure("increment", "counter", on: .test) {
                    count += 1
                    return count
                }
                return value
            }
        }
        #expect(await Counter().increment() == 1)
    }

    @Test func endReturnsTheElapsedTime() {
        let log = Logy<TestEntry>()
        let interval = log.begin("work", "GET", detail: "/users/42", on: LogChannel(.test, "own", signposts: .ownCategory))
        #expect(log.end(interval, "200") >= .zero)
    }
}
