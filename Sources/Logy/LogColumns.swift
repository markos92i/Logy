//
//  LogColumns.swift
//  Logy
//
//  Created by Marcos del Castillo Camacho on 27/10/2026.
//

/// Aligns `\t`-separated columns so related entries (a request and its response) line up.
public enum LogColumns {
    public static let widths = [7, 10, 9]
    public static let gap = 4

    public static func align(_ line: String) -> String {
        var columns = line.split(separator: "\t", omittingEmptySubsequences: false)
        while columns.count > 1, columns.last?.isEmpty == true { columns.removeLast() }
        return columns.enumerated().map { index, column in
            guard index < columns.count - 1 else { return String(column) }
            let width = index < widths.count ? widths[index] : 0
            return column + String(repeating: " ", count: max(width - cells(column), 0) + gap)
        }.joined()
    }

    /// An SF Symbol (private use planes) takes about two monospaced console cells.
    private static func cells(_ text: Substring) -> Int {
        text.unicodeScalars.reduce(0) { $0 + ($1.value >= 0xF0000 ? 2 : 1) }
    }
}
