//
//  DebugLogger.swift
//  DocumentViewer
//
//  Copyright © 2023 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
//

import Foundation

// MARK: - Protocol

public protocol DebugLogger {

    func log(_ text: String)
    func log(_ items: [Any])

    func print(
        _ items: [Any],
        prefix: String?,
        separator: String,
        terminator: String
    )
}

// MARK: - Default Implementation

public extension DebugLogger {

    func print(
        _ items: [Any],
        prefix: String? = nil,
        separator: String = " ",
        terminator: String = "\n"
    ) {
#if DEBUG
        let prefix = "[" + (prefix ?? String(describing: Self.self)) + "]"

        guard items.count > 1 else {
            Swift.print(prefix + separator + "\(items[0])", separator: separator, terminator: terminator)
            return
        }

        Swift.print([prefix] + items, separator: separator, terminator: terminator)
#endif
    }
}

// MARK: - Class Conformance

public extension DebugLogger where Self: AnyObject {

    func log(_ text: String) {
        self.print([text])
    }

    func log(_ items: [Any]) {
        self.print(items)
    }
}

// MARK: - Protocol Conformance

private final class DebugLog: DebugLogger {
    public static let shared: DebugLogger = DebugLog()
}

// MARK: - Globlal Functions

public func printDebug(
    _ items: Any...,
    prefix: String? = nil,
    separator: String = " ",
    terminator: String = "\n"
) {
    DebugLog.shared.print(
        items,
        prefix: prefix,
        separator: separator,
        terminator: terminator
    )
}

public func printDebug(
    _ items: Any...,
    type: AnyClass,
    separator: String = " ",
    terminator: String = "\n"
) {
    DebugLog.shared.print(
        items,
        prefix: String(describing: type.self),
        separator: separator,
        terminator: terminator
    )
}
