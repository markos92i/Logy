//
//  Logy+Measure.swift
//  Logy
//
//  Created by Marcos del Castillo Camacho on 27/10/2026.
//

import os

/// An open interval: a bar in Instruments and the time it took.
public struct LogInterval: Sendable {
    let name: StaticString
    let channel: LogChannel
    let state: OSSignpostIntervalState
    let start: ContinuousClock.Instant
}

extension Logy {
    /// Opens an interval. `label` is always public; `detail` is private outside Debug.
    public func begin(_ name: StaticString, _ label: String, detail: String? = nil, on channel: LogChannel) -> LogInterval {
        let signposter = channel.signposter
        // Own ID per interval: concurrent intervals can't share `.exclusive`.
        let id = signposter.makeSignpostID()
        let state: OSSignpostIntervalState
        if let detail {
            #if DEBUG
            state = signposter.beginInterval(name, id: id, "\(label, privacy: .public) \(detail, privacy: .public)")
            #else
            state = signposter.beginInterval(name, id: id, "\(label, privacy: .public) \(detail, privacy: .private)")
            #endif
        } else {
            state = signposter.beginInterval(name, id: id, "\(label, privacy: .public)")
        }
        return LogInterval(name: name, channel: channel, state: state, start: .now)
    }

    /// Closes the interval with a public `result` and returns how long it took.
    @discardableResult
    public func end(_ interval: LogInterval, _ result: String = "") -> Duration {
        interval.channel.signposter.endInterval(interval.name, interval.state, "\(result, privacy: .public)")
        return ContinuousClock.now - interval.start
    }

    /// Runs `work` inside an interval and returns its value with the time it took.
    public func measure<T, E: Error>(
        _ name: StaticString,
        _ label: String,
        detail: String? = nil,
        on channel: LogChannel,
        _ work: () async throws(E) -> T
    ) async throws(E) -> (value: T, elapsed: Duration) {
        let interval = begin(name, label, detail: detail, on: channel)
        do throws(E) {
            let value = try await work()
            return (value, end(interval))
        } catch {
            end(interval, "failed")
            throw error
        }
    }
}
