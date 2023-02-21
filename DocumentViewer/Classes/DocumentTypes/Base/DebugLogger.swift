//
//  DebugLogger.swift
//  DocumentViewer
//
//  Created by Alejandro Melo Domínguez on 21-02-23.
//

import Foundation

public protocol DebugLogger {

    /// Allows the user to print messages to the Xcode debugger.
    /// Works the same as `print()`, but only prints if the `DEBUG` macro is `1`.
    func debugLog(
        _ items: Any...,
        separator: String,
        terminator: String
    )
}

extension DebugLogger {

    public func debugLog(
        _ items: Any...,
        separator: String = " ",
        terminator: String = "\n"
    ) {
        #if targetEnvironment(simulator) && DEBUG
        let prefixes = [
            "[\(String(describing: self))]"
        ]
        print(prefixes + items, separator: separator, terminator: terminator)
        #endif
    }
}
