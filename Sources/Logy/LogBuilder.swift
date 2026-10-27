//
//  LogBuilder.swift
//  Logy
//
//  Created by Marcos del Castillo Camacho on 27/10/2026.
//

/// Composes log lines from strings, string arrays, optionals and conditionals.
@resultBuilder
public enum LogBuilder {
    public static func buildBlock(_ components: [String]...) -> [String] { components.flatMap { $0 } }
    public static func buildExpression(_ expression: String) -> [String] { [expression] }
    public static func buildExpression(_ expression: [String]) -> [String] { expression }
    public static func buildOptional(_ component: [String]?) -> [String] { component ?? [] }
    public static func buildEither(first component: [String]) -> [String] { component }
    public static func buildEither(second component: [String]) -> [String] { component }
    public static func buildArray(_ components: [[String]]) -> [String] { components.flatMap { $0 } }
}
