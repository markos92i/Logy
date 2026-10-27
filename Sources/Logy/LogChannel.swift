//
//  LogChannel.swift
//  Logy
//
//  Created by Marcos del Castillo Camacho on 27/10/2026.
//

import os

/// A category inside a subsystem (`http`, `disk`…): where its lines and intervals go.
public struct LogChannel: Sendable {
    /// Where the channel's intervals appear in Instruments.
    public enum Signposts: Sendable {
        /// The "Points of Interest" lane, present in the usual templates.
        case pointsOfInterest
        /// The channel's own category, shown by the "os_signpost" instrument.
        case ownCategory
    }

    public let subsystem: LogSubsystem
    public let category: String
    let logger: os.Logger
    let signposter: OSSignposter

    public init(_ subsystem: LogSubsystem, _ category: String, signposts: Signposts = .pointsOfInterest) {
        self.subsystem = subsystem
        self.category = category
        self.logger = os.Logger(subsystem: subsystem.name, category: category)
        self.signposter = switch signposts {
        case .pointsOfInterest: OSSignposter(subsystem: subsystem.name, category: .pointsOfInterest)
        case .ownCategory: OSSignposter(subsystem: subsystem.name, category: category)
        }
    }
}
